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
struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @Binding var activeTour: TourResponse?
    @Binding var selectedTab: ContentView.Tab
    @Binding var showDetail: Bool
    @Binding var detailId: String
    @Binding var zoomOnLocation: Bool
    @Binding var changeMapType: Bool
    @Binding var annotations: [CustomPointAnnotation]
    @Binding var polylines: [MKPolyline]
    let region: MKCoordinateRegion
    let mapType: MKMapType
    let showsUserLocation: Bool
    let userTrackingMode: MKUserTrackingMode
    let identifier = "Annotation"
    let clusterIdentifier = "Cluster"
    let mapView = MKMapView()
    
    /**
     
     */
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        setupManager()
        mapView.delegate = context.coordinator
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        mapView.setRegion(region, animated: true)
        mapView.mapType = mapType
        mapView.showsUserLocation = showsUserLocation
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        
        mapView.addAnnotations(annotations)
        mapView.addOverlays(polylines)
        
        return mapView
    }
    
    /**
     
     */
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        if changeMapType {
            DispatchQueue.main.async {
                uiView.mapType = mapType
            }
        }
        if zoomOnLocation {
            DispatchQueue.main.async {
                uiView.setRegion(region, animated: true)
                zoomOnLocation = false
            }
        }
        
        if Set(context.coordinator.annotations) != Set(annotations) {
            DispatchQueue.main.async {
                context.coordinator.annotations = annotations
                uiView.removeAnnotations(uiView.annotations)
                uiView.addAnnotations(annotations)
            }
            
        }
        
        
        if Set(context.coordinator.polylines) != Set(polylines) {
            DispatchQueue.main.async {
                context.coordinator.polylines = polylines
                uiView.removeOverlays(uiView.overlays)
                var coordinates: Array<MKMapPoint> = []
                for polyline in polylines {
                    coordinates.append(contentsOf: Array(UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount)))
                    uiView.addOverlay(polyline)
                }
                if !coordinates.isEmpty {
                    let polygon = MKPolyline(points: coordinates, count: coordinates.count)
                    uiView.setVisibleMapRect(polygon.boundingMapRect, edgePadding: .init(top: 64, left: 64, bottom: 64, right: 64), animated: true)
                } else {
                    let coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
                    uiView.setRegion(coordinateRegion, animated: true)
                }
            }
        }
    }
    
    /**
     
     */
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self, activeTour: $activeTour, detailId: $detailId, showDetail: $showDetail, selectedTab: $selectedTab, annotations: annotations, polylines: polylines)
    }
    
    /**
     
     */
    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var activeTour: TourResponse?
        @Binding var showDetail: Bool
        @Binding var detailId: String
        @Binding var selectedTab: ContentView.Tab
        var annotations: [CustomPointAnnotation]
        var polylines: [MKPolyline]
        private let mapView: MapView
        private var route: MKRoute? = nil
        let identifier = "Annotation"
        let clusterIdentifier = "Cluster"
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
        init(_ mapView: MapView, activeTour: Binding<TourResponse?>, detailId: Binding<String>, showDetail: Binding<Bool>, selectedTab: Binding<ContentView.Tab>, annotations: [CustomPointAnnotation], polylines: [MKPolyline]) {
            self.mapView = mapView
            _activeTour = activeTour
            _detailId = detailId
            _showDetail = showDetail
            _selectedTab = selectedTab
            self.annotations = annotations
            self.polylines = polylines
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
