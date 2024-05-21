//
//  MapTab.swift
//  historic city tours
//
//  Created by Tim Bachmann on 03.03.2024.
//

import SwiftUI
import MapKit
import ARKit

/**
 Main Tab displaying a full sized map and controls to navigate to gallery, camera view and some map options.
 */
struct MapTab: View {
    
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    private let buttonSize: CGFloat = 48.0
    private let buttonOpacity: CGFloat = 0.95
    @Binding var selectedTab: ContentView.Tab
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
    @State private var showCamera: Bool = false
    @State private var includePublic: Bool = false
    @State private var radius: Double = 2.0
    @State private var startDate: Date = Date(timeIntervalSince1970: -3155673600.0)
    @State private var endDate: Date = Date()
    @State private var queryText: String = ""
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MapView(activeTour: $multimediaObjectData.activeTour, selectedTab: $selectedTab, showDetail: $showDetail, detailId: $detailId, zoomOnLocation: $zoomOnLocation, changeMapType: $changeMapType, applyAnnotations: $applyAnnotations, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
                    .edgesIgnoringSafeArea(.top)
                    
                
                if $multimediaObjectData.activeTour.wrappedValue == nil {
                    ZStack {
                        VStack(spacing: 12) {
                            Text("Currently, there is no active tour to display. Try selecting one in the")
                            Button(action: {
                                $selectedTab.wrappedValue = .browse
                            }, label: {
                                Text("Browse Tab").foregroundStyle(Color.fireOrange)
                            })
                        }.padding()
                        
                    }
                    .frame(width: 296, height: 124)
                    .background(Color.white)
                    .cornerRadius(8, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                    .shadow(radius: 12)
                }
                
                if $mapStyleSheetVisible.wrappedValue {
                    ZStack {
                        Color(UIColor.systemBackground)
                        VStack {
                            Text("Map Style")
                            Spacer()
                            Picker("", selection: $mapType) {
                                Text("Standard").tag(MKMapType.standard)
                                Text("Satellite").tag(MKMapType.satellite)
                                Text("Flyover").tag(MKMapType.hybridFlyover)
                                Text("Hybrid").tag(MKMapType.hybrid)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .font(.largeTitle)
                        }.padding()
                    }
                    .frame(width: 300, height: 100)
                    .cornerRadius(20).shadow(radius: 20)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(.stack)
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: {
            requestNotificationAuthorization()
            applyAnnotations = true
        })
    }
}

extension MapTab {
    
    /**
     Called if new map type is selected and requests change on map by changing state variable
     */
    func applyMapTypeChange() {
        changeMapType = true
        mapStyleSheetVisible = false
        MKMapView.appearance().mapType = mapType
    }
    
    /**
     Called if location button is pressed and requests zoom on map by changing state variable.
     */
    func requestZoomOnLocation() {
        zoomOnLocation = true
        let span: Double = locationButtonCount % 2 == 0 ? 0.005001 : 0.005002
        coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        locationButtonCount += 1
    }
    
    /**
     Returns cache directory path
     */
    func getCacheDirectoryPath() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    /**
     Requests authorization to send notifications
     */
    func requestNotificationAuthorization() {
        
        let nc = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        nc.requestAuthorization(options: options) { granted, _ in
            print("\(#function) Permission granted: \(granted)")
            guard granted else { return }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        MapTab(selectedTab: .constant(.map))
    }
}

/**
 Struct to represent a rectangle with rounded corners
 */
struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    
    /**
     View extension to apply the rounded corner struct to any view.
     */
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

//extension MKCoordinateRegion: Equatable {
//
//    /**
//
//     */
//    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
//        if lhs.center.latitude == rhs.center.latitude && lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta {
//            return true
//        } else {
//            return false
//        }
//    }
//}

extension UINavigationController: UIGestureRecognizerDelegate {
    
    /**
     Add pop gesture recognizer to UINavigationController to recognize swipe back gestures
     */
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    /**
     Gesture reognizer should be active if there is more than one view controller.
     */
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

