//
//  MapView.swift
//  historic city tours
//
//  Created by Tim Bachmann on 03.03.2024.
//

import SwiftUI
import MapKit
import OpenAPIClient

/**
 
 */
struct MapViewDetail: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @Binding var activeTour: TourResponse
    @Binding var selectedTab: ContentView.Tab
    @Binding var showDetail: Bool
    @Binding var detailId: String
    @Binding var zoomOnLocation: Bool
    @Binding var changeMapType: Bool
    @Binding var applyAnnotations: Bool
    let region: MKCoordinateRegion
    let mapType: MKMapType
    let showsUserLocation: Bool
    let userTrackingMode: MKUserTrackingMode
    let identifier = "AnnotationDetail"
    let clusterIdentifier = "ClusterDetail"
    let mapView = MKMapView()
    
    /**
     
     */
    func makeUIView(context: UIViewRepresentableContext<MapViewDetail>) -> MKMapView {
        setupManager()
        mapView.delegate = context.coordinator
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: clusterIdentifier)
        mapView.setRegion(region, animated: true)
        mapView.mapType = mapType
        mapView.showsUserLocation = showsUserLocation
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        return mapView
    }
    
    /**
     
     */
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapViewDetail>) {
        if changeMapType {
            uiView.mapType = mapType
        }
        if zoomOnLocation {
            uiView.setRegion(region, animated: true)
            zoomOnLocation = false
        }
        if applyAnnotations {
            uiView.removeAnnotations(uiView.annotations)
            addAnnotations(to: uiView)
            applyAnnotations = false
        }
    }
    
    func addAnnotations(to mapView: MKMapView) {
        for mmObjectId in activeTour.multimediaObjects! {
            let mmObject = multimediaObjectData.getMultimediaObject(id: mmObjectId)
            
            if mmObject?.position != nil && mmObject != nil {
                var finalImage: UIImage = UIImage(systemName: "mappin.and.ellipse")!
                finalImage = finalImage.scalePreservingAspectRatio(targetSize: CGSize(width: 48.0, height: 48.0))
                
                let annotation = ImageAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: mmObject!.position!.lat, longitude: mmObject!.position!.lng),
                    title: mmObject!.title!,
                    image: finalImage,
                    subtitle: mmObject!.source!,
                    id: mmObject!.id!
                )
                
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    /**
     
     */
    func makeCoordinator() -> MapViewDetail.Coordinator {
        Coordinator(self, activeTour: $activeTour, detailId: $detailId, showDetail: $showDetail, selectedTab: $selectedTab)
    }
    
    /**
     
     */
    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var activeTour: TourResponse
        @Binding var showDetail: Bool
        @Binding var detailId: String
        @Binding var selectedTab: ContentView.Tab
        private let mapView: MapViewDetail
        private var route: MKRoute? = nil
        let identifier = "AnnotationDetail"
        let clusterIdentifier = "ClusterDetail"
        private let maxZoomLevel = 11
        private var previousZoomLevel: Int?
        private var currentZoomLevel: Int?  {
            willSet { self.previousZoomLevel = self.currentZoomLevel }
            didSet { checkZoomLevel() }
        }
        private var shouldCluster: Bool {
            if let zoomLevel = self.currentZoomLevel, zoomLevel <= maxZoomLevel { return false }
            return true
        }
        
        /**
         
         */
        private func checkZoomLevel() {
            guard let currentZoomLevel = self.currentZoomLevel else { return }
            guard let previousZoomLevel = self.previousZoomLevel else { return }
            var refreshRequired = false
            if currentZoomLevel > self.maxZoomLevel && previousZoomLevel <= self.maxZoomLevel {
                refreshRequired = true
            }
            if currentZoomLevel <= self.maxZoomLevel && previousZoomLevel > self.maxZoomLevel {
                refreshRequired = true
            }
            if refreshRequired {
                let annotations = self.mapView.mapView.annotations
                self.mapView.mapView.removeAnnotations(annotations)
                self.mapView.mapView.addAnnotations(annotations)
            }
        }
        
        /**
         
         */
        init(_ mapView: MapViewDetail, activeTour: Binding<TourResponse>, detailId: Binding<String>, showDetail: Binding<Bool>, selectedTab: Binding<ContentView.Tab>) {
            self.mapView = mapView
            _activeTour = activeTour
            _detailId = detailId
            _showDetail = showDetail
            _selectedTab = selectedTab
        }
        
        /**
         
         */
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let zoomWidth = mapView.visibleMapRect.size.width
            let zoomLevel = Int(log2(zoomWidth))
            self.currentZoomLevel = zoomLevel
        }
        
        /**
         
         */
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is ImageAnnotation {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! ImageAnnotationView
                annotationView.canShowCallout = true
                annotationView.annotation = annotation
                annotationView.clusteringIdentifier = self.shouldCluster ? identifier : nil
                return annotationView
                
            } else if annotation is MKClusterAnnotation {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: clusterIdentifier, for: annotation) as! ClusterAnnotationView
                annotationView.canShowCallout = true
                annotationView.annotation = annotation
                return annotationView
            } else {
                return nil
            }
        }
        
        /**
         
         */
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard view is ImageAnnotationView else { return }
            if view.annotation is ImageAnnotation {
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                let directionsButton: UIButton = UIButton(type: .detailDisclosure)
                directionsButton.tag = 123
                directionsButton.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.diamond"), for: .normal)
                view.leftCalloutAccessoryView = directionsButton
            }
        }
        
        /**
         
         */
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard view is ImageAnnotationView else { return }
            
            if let imageAnnotation = view.annotation as? ImageAnnotation {
                detailId = imageAnnotation.id!
                
                if let controlDetail = control as? UIButton {
                    if controlDetail.tag == 123 {
                        //self.navigationImage = self.mapImages[self.mapImages.firstIndex(where: {$0.id == imageAnnotation.id})!]
                        selectedTab = .ar
                    } else {
                        showDetail = true
                    }
                }
            }
        }
        
        /**
         
         */
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyOverlay = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyOverlay)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            } else {
                return MKOverlayRenderer()
            }
        }
    }
}
