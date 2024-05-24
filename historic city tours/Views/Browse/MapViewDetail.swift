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
    @Binding var applyRoute: Bool
    @Binding var polylines: [MKPolyline?]
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
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
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
        
        if applyRoute {
            if !polylines.isEmpty {
                removePolylines(from: uiView)
            }
            addRoute(to: uiView)
            applyRoute = false
        }
    }
    
    func addAnnotations(to mapView: MKMapView) {
        for mmObjectId in activeTour.multimediaObjects! {
            let mmObject = multimediaObjectData.getMultimediaObject(id: mmObjectId)
            
            if mmObject?.position != nil && mmObject != nil {
                let annotation = CustomPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: mmObject!.position!.lat, longitude: mmObject!.position!.lng), title: mmObject!.title!, subtitle: mmObject!.source!, id: mmObject!.id!)
                
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func addRoute(to mapView: MKMapView) {
        var coordinates: Array<MKMapPoint> = []
        for polyline in polylines {
            if let polyline = polyline {
                coordinates.append(contentsOf: Array(UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount)))
                mapView.addOverlay(polyline)
            }
        }
        let polygon = MKPolyline(points: coordinates, count: coordinates.count)
        mapView.setVisibleMapRect(polygon.boundingMapRect, edgePadding: .init(top: 40, left: 40, bottom: 40, right: 40), animated: true)
    }
    
    func removePolylines(from mapView: MKMapView) {
        for polyline in polylines {
            if let polyline = polyline {
                mapView.removeOverlay(polyline)
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
            
            if annotation is CustomPointAnnotation {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! MKMarkerAnnotationView
                annotationView.canShowCallout = true
                annotationView.markerTintColor = UIColor(red: 0.97, green: 0.51, blue: 0.33, alpha: 1.00)
                annotationView.annotation = annotation
                return annotationView
                
            } else {
                return nil
            }
        }
        
        /**
         
         */
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard view is MKMarkerAnnotationView else { return }
            if view.annotation is CustomPointAnnotation {
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }
        
        /**
         
         */
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard view is MKMarkerAnnotationView else { return }
            
            if let customAnnotation = view.annotation as? CustomPointAnnotation {
                detailId = customAnnotation.id!
                showDetail = true
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
