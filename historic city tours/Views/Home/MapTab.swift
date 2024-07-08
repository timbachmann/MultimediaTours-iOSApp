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
    @State private var applyRoute: Bool = false
    @State private var polylines: [MKPolyline?] = []
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MapView(activeTour: $multimediaObjectData.activeTour, selectedTab: $selectedTab, showDetail: $showDetail, detailId: $detailId, zoomOnLocation: $zoomOnLocation, changeMapType: $changeMapType, applyAnnotations: $applyAnnotations, applyRoute: $applyRoute, polylines: $polylines, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
                    .edgesIgnoringSafeArea(.top)
                
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            VStack(spacing: 0) {
                                Button(action: {
                                    mapStyleSheetVisible = !mapStyleSheetVisible
                                }, label: {
                                    Image(systemName: "map")
                                        .padding()
                                        .foregroundColor(Color.accentColor)
                                })
                                .frame(width: buttonSize, height: buttonSize)
                                .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                .cornerRadius(10.0, corners: [.topLeft, .topRight])
                                
                                Divider()
                                    .frame(width: buttonSize)
                                    .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
                                Button(action: {
                                    requestZoomOnLocation()
                                }, label: {
                                    Image(systemName: "location")
                                        .padding()
                                        .foregroundColor(Color.accentColor)
                                })
                                .frame(width: buttonSize, height: buttonSize)
                                .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                .cornerRadius(10.0, corners: [.bottomLeft, .bottomRight])
                            }
                            Spacer()
                        }
                        .padding(8.0)
                    }
                }
                    
                
                if $multimediaObjectData.activeTour.wrappedValue == nil {
                    ZStack {
                        VStack {
                            Text("Currently, there is no active tour to display. Try selecting one in the")
                            Button(action: {
                                $selectedTab.wrappedValue = .browse
                            }, label: {
                                Text("Browse Tab").foregroundStyle(Color.fireOrange)
                            })
                        }.padding()
                        
                    }
                    .frame(width: 264, height: 124)
                    .background(Color(UIColor.systemBackground).opacity(0.95))
                    .cornerRadius(8, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                    .shadow(radius: 12)
                }
                
                if $multimediaObjectData.activeTour.wrappedValue != nil {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                multimediaObjectData.activeTourObjectIndex = nil
                                multimediaObjectData.activeTour = nil
                                applyRoute = true
                                applyAnnotations = true
                            }, label: {
                                Image(systemName: "xmark")
                                    .padding()
                                    .foregroundColor(Color.accentColor)
                            })
                            .frame(width: 48.0, height: 48.0)
                            .background(Color(UIColor.systemBackground).opacity(0.95))
                            .cornerRadius(10.0, corners: .allCorners)
                        }
                    }
                    .padding()
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
                            .onChange(of: mapType) { tag in
                                applyMapTypeChange()
                            }
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
            fetchRoute()
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
    
    func fetchRoute() {
        if $multimediaObjectData.activeTour.wrappedValue != nil {
            let dispatchGroup = DispatchGroup()
            var positions: [MKMapItem] = []
            
            let userPositionStart = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
            userPositionStart.name = "Start"
            positions.append(userPositionStart)
            
            for mmObjectId in $multimediaObjectData.activeTour.wrappedValue!.multimediaObjects! {
                if let position = multimediaObjectData.getMultimediaObject(id: mmObjectId)?.position {
                    let currItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng)))
                    currItem.name = mmObjectId
                    positions.append(currItem)
                }
            }
            
            let userPositionFinish = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
            userPositionFinish.name = "Finish"
            positions.append(userPositionFinish)
            
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

