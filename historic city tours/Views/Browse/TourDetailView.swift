//
//  TourDetailView.swift
//  historic city tours
//
//  Created by Tim Bachmann on 06.05.2024.
//

import SwiftUI
import OpenAPIClient
import MapKit

struct TourDetailView: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var tour: TourResponse
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @State var multimediaObjects: [MultimediaObjectResponse] = []
    @State var isFetching: Bool = true
    @State private var showFavoritesOnly = false
    @State private var mapStyleSheetVisible: Bool = false
    @State private var locationButtonCount: Int = 0
    @State private var isLoading: Bool = false
    @State private var detailId: String = ""
    @State private var showGallery: Bool = false
    @State private var showFilter: Bool = false
    @State private var locationManager = CLLocationManager()
    @State private var trackingMode: MKUserTrackingMode = .follow
    @State private var mapType: MKMapType = .standard
    @State private var showDetail: Bool = false
    @State private var uploadProgress = 0.0
    @State private var showUploadProgress: Bool = false
    @State private var zoomOnLocation: Bool = false
    @State private var changeMapType: Bool = false
    @State private var applyAnnotations: Bool = false
    @State private var applyRoute: Bool = false
    @State private var polylines: [MKPolyline?] = []
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
    
    @State private var TagColors: Array<Color> = [
        Color.tag1,
        Color.tag2,
        Color.tag3,
        Color.tag4,
        Color.tag5,
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            MapViewDetail(activeTour: $tour, selectedTab: $selectedTab, showDetail: $showDetail, detailId: $detailId, zoomOnLocation: $zoomOnLocation, changeMapType: $changeMapType, applyAnnotations: $applyAnnotations, applyRoute: $applyRoute, polylines: $polylines, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
                        .frame(maxHeight: 250)
            
            List {
                if $tour.author.wrappedValue != nil {
                    Section(header: Text("Author")) {
                        HStack{
                            Text($tour.author.wrappedValue ?? "")
                            Spacer()
                        }
                    }
                }
                
                if $tour.source.wrappedValue != nil {
                    Section(header: Text("Source")) {
                        HStack{
                            Text($tour.source.wrappedValue ?? "")
                            Spacer()
                        }
                    }
                }
                
                if $tour.tags.wrappedValue?.count != 0 {
                    Section(header: Text("Tags")) {
                        HStack{
                            ForEach($tour.tags.wrappedValue ?? [], id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 4.0)
                                    .padding(.vertical, 2.0)
                                    .font(.system(size: 12))
                                    .background(TagColors[Int.random(in: 0..<TagColors.count)])
                                    .cornerRadius(3.0, corners: .allCorners)
                            }
                        }
                    }
                }
            
                if $tour.multimediaObjects.wrappedValue?.count != 0 {
                    Section(header: Text("Multimedia-Objects")) {
                        ForEach($multimediaObjects.wrappedValue, id: \.self) { mmO in
                            NavigationLink(destination: {
                                MultimediaObjectDetailView(multimediaObject: mmO)
                            }, label: {
                                HStack {
                                    Text(mmO.title ?? "")
                                    Spacer()
                                }.redacted(reason: $isFetching.wrappedValue ? /*@START_MENU_TOKEN@*/.placeholder/*@END_MENU_TOKEN@*/ : [])
                            })
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationTitle($tour.title.wrappedValue ?? "Tour")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            fetchMultimediaObjects()
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    $multimediaObjectData.activeTour.wrappedValue = tour
                    $multimediaObjectData.activeTourObjectIndex.wrappedValue = 0
                    $selectedTab.wrappedValue = .map
                }, label: {
                    HStack{
                        Text("Start")
                        Image(systemName: "arrow.triangle.turn.up.right.diamond")
                            .foregroundColor(Color.accentColor)
                    }
                    
                })
            }
        }
    }
}

extension TourDetailView {
    
    func fetchMultimediaObjects() {
        multimediaObjects = []
        for id in $tour.multimediaObjects.wrappedValue! {
            let mmObject = multimediaObjectData.getMultimediaObject(id: id)
            if mmObject != nil {
                multimediaObjects.append(mmObject!)
            }
        }
        isFetching = false
        applyAnnotations = true
        fetchRoute()
    }
    
    func fetchRoute() {
        let dispatchGroup = DispatchGroup()
        var positions: [MKMapItem] = []
        
        for mmObjectId in $tour.multimediaObjects.wrappedValue! {
            if let position = multimediaObjectData.getMultimediaObject(id: mmObjectId)?.position {
                let currItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng)))
                currItem.name = mmObjectId
                positions.append(currItem)
            }
        }
        
        if !positions.isEmpty {
            positions.append(positions.first!)
        
            for i in 1 ..< positions.count {
                dispatchGroup.enter()
                
                let request = MKDirections.Request()
                request.transportType = .walking
                request.source = positions[i-1]
                request.destination = positions[i]
                request.requestsAlternateRoutes = false
                
                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let mapRoute = response?.routes.first else {
                        return
                    }
                    polylines.append(mapRoute.polyline)
                }
            }
            dispatchGroup.notify(queue: .main) {
                applyRoute = true
            }
            
        } else {
            dispatchGroup.notify(queue: .main) {
                zoomOnLocation = true
            }
        }
    }
}
