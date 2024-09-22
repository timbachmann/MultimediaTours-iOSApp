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
struct MapViewObjectDetail: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var locationManager = CLLocationManager()
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @Binding var mmObject: MultimediaObjectResponse
    @Binding var selectedTab: ContentView.Tab
    @Binding var zoomOnLocation: Bool
    @Binding var changeMapType: Bool
    @Binding var annotations: [CustomPointAnnotation]
    let region: MKCoordinateRegion
    let mapType: MKMapType
    let showsUserLocation: Bool
    let userTrackingMode: MKUserTrackingMode
    let identifier = "AnnotationDetail"
    let clusterIdentifier = "ClusterDetail"
    let mapView = MKMapView()
    
    /**
     
     */
    func makeUIView(context: UIViewRepresentableContext<MapViewObjectDetail>) -> MKMapView {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = context.coordinator
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        mapView.setRegion(region, animated: true)
        mapView.mapType = mapType
        mapView.showsUserLocation = showsUserLocation
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        
        mapView.addAnnotations(annotations)
        var coordinate: CLLocationCoordinate2D? = nil
        for annotation in annotations {
            coordinate = annotation.coordinate
        }
        if let firstCoordinate = coordinate {
            let coordinateRegion = MKCoordinateRegion.init(center: firstCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        return mapView
    }
    
    /**
     
     */
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapViewObjectDetail>) {
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
                var coordinate: CLLocationCoordinate2D? = nil
                for annotation in annotations {
                    coordinate = annotation.coordinate
                }
                if let firstCoordinate = coordinate {
                    let coordinateRegion = MKCoordinateRegion.init(center: firstCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
                    uiView.setRegion(coordinateRegion, animated: true)
                }
                
                context.coordinator.annotations = annotations
                uiView.removeAnnotations(uiView.annotations)
                uiView.addAnnotations(annotations)
            }
        }
    }
    
    /**
     
     */
    func makeCoordinator() -> MapViewObjectDetail.Coordinator {
        Coordinator(self, mmObject: $mmObject, selectedTab: $selectedTab, annotations: annotations)
    }
    
    /**
     
     */
    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var mmObject: MultimediaObjectResponse
        @Binding var selectedTab: ContentView.Tab
        var annotations: [CustomPointAnnotation]
        private let mapView: MapViewObjectDetail
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
        init(_ mapView: MapViewObjectDetail, mmObject: Binding<MultimediaObjectResponse>, selectedTab: Binding<ContentView.Tab>, annotations: [CustomPointAnnotation]) {
            self.mapView = mapView
            _mmObject = mmObject
            _selectedTab = selectedTab
            self.annotations = annotations
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
    }
}
