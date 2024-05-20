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
    @Binding var tour: TourResponse
    @State var multimediaObjects: [MultimediaObjectResponse] = []
    @State var isFetching: Bool = true
    @State var selectedTab: ContentView.Tab = .browse
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
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
    
    var body: some View {
        VStack(spacing: 0) {
            MapView(selectedTab: $selectedTab, showDetail: $showDetail, detailId: $detailId, zoomOnLocation: $zoomOnLocation, changeMapType: $changeMapType, applyAnnotations: $applyAnnotations, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
                        .frame(maxHeight: 250)
            HStack{
                Spacer()
                Button(action: {
                    
                }, label: {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond")
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        Text("Start Tour")
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                    }
                })
                .frame(width: 200.0, height: 40.0, alignment: .center)
                .background(Color.fireOrange)
                .cornerRadius(8, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                .padding(.vertical, 8.0)
                Spacer()
            }
            .background(Color.sand)
            
            List {
                Section(header: Text("Source")) {
                    HStack{
                        Text($tour.source.wrappedValue ?? "")
                        Spacer()
                    }
                }
                Section(header: Text("Author")) {
                    HStack{
                        Text($tour.author.wrappedValue ?? "")
                        Spacer()
                    }
                }
            
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
            .background(Color.sand)
            .scrollContentBackground(.hidden)
            Spacer()
        }
        .background(Color.sand)
        .toolbarBackground(Color.sand, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle($tour.title.wrappedValue ?? "Tour")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchMultimediaObjects)
    }
}

extension TourDetailView {
    
    func fetchMultimediaObjects() {
        multimediaObjects = []
        for id in $tour.multimediaObjects.wrappedValue! {
            MultimediaObjectsAPI.multimediaObjectsIdGet(id: id) { (response, error) in
                if response != nil {
                    multimediaObjects.append(response!)
                }
            }
        }
        isFetching = false
    }
}
