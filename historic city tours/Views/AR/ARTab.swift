//
//  ARTab.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import SwiftUI
import ARKit
import MapKit
import AVKit
import OpenAPIClient


struct ARTab: View {
    
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var settingsModel: SettingsModel
    
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var arDelegate = ARDelegate()
    
    @State private var detailImage: Image?
    @State private var player: AVPlayer?
    @State var polyline: MKPolyline? = nil
    @State var directionsRequestSent: Bool = false
    @State var showDetailPanel: Bool = false
    @State var currLocation: CLLocation = CLLocation()
    @State var navigationObject: MultimediaObjectResponse? = nil
    @State var nodes: [SCNNode] = []
    @State var polyNodes: [SCNNode] = []
    @State var reset: Int = 0
    
    var body: some View {
        ZStack {
            Color.black
            if selectedTab == .ar {
                ARViewRepresentable(arDelegate: arDelegate, nodes: $nodes, polyNodes: $polyNodes, currLocation: $currLocation, reset: $reset)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .padding()
                    .foregroundColor(Color.accentColor)
            }
            
            VStack {
                HStack {
                    if settingsModel.debugMode == true {
                        VStack(alignment: .leading) {
                            Text(arDelegate.getMessage())
                                .foregroundColor(Color.primary)
                                .font(.system(size: 12.0))
                            Text("Object Index: " + String(multimediaObjectData.activeTourObjectIndex ?? -1))
                                .foregroundColor(Color.primary)
                                .font(.system(size: 12.0))
                            Spacer()
                        }
                        .frame(height: 128.0)
                        .padding()
                        .padding(.top, 24.0)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        RadarView(navigationImage: $navigationObject, polyline: $polyline)
                            .frame(width: 96.0, height: 96.0)
                            .clipShape(
                                Circle()
                                    .size(width: 120.0, height: 96.0)
                                    .offset(x: -12.0, y: 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(uiColor: UIColor.systemBackground), lineWidth: 4)
                            )
                            .offset(x: 0.0, y: 40)
                            .padding(.bottom, 64.0)
                        
                        VStack(spacing: 0) {
                            if multimediaObjectData.activeTourObjectIndex != nil {
                                // ABORT Button
                                Button(action: {
                                    abortTour()
                                }, label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(Color.accentColor)
                                })
                                .frame(width: 48.0, height: 48.0)
                                .background(Color(UIColor.systemBackground).opacity(0.95))
                                .cornerRadius(10.0, corners: [.topLeft, .topRight])
                                
                                Divider()
                                    .frame(width: 48.0, height: 1.0)
                                    .background(Color(UIColor.systemBackground).opacity(0.95))
                                
                                // RESET Button
                                Button(action: {
                                    resetArView()
                                }, label: {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .foregroundColor(Color.accentColor)
                                })
                                .frame(width: 48.0, height: 48.0)
                                .background(Color(UIColor.systemBackground).opacity(0.95))
                                .cornerRadius(10.0, corners: [.bottomLeft, .bottomRight])
                            }
                        }
                    }
                }
                Spacer()
                HStack (alignment: .center, spacing: 0) {
                    if multimediaObjectData.activeTourObjectIndex != nil {
                        // PREVIOUS Button
                        Button(action: {
                            previousTourItem()
                        }, label: {
                            Image(systemName: "backward")
                                .foregroundColor(Color.accentColor)
                        })
                        .frame(width: 48.0, height: 48.0)
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        .cornerRadius(10.0, corners: [.topLeft, .bottomLeft])
                        
                        Divider()
                            .frame(width: 1.0, height: 48.0)
                            .background(Color(UIColor.systemBackground).opacity(0.95))
                        
                        // DETAIL PANEL Button
                        Button(action: {
                            $showDetailPanel.wrappedValue.toggle()
                        }, label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.accentColor)
                        })
                        .frame(width: 48.0, height: 48.0)
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        
                        Divider()
                            .frame(width: 1.0, height: 48.0)
                            .background(Color(UIColor.systemBackground).opacity(0.95))
                        
                        // NEXT Button
                        Button(action: {
                            nextTourItem()
                        }, label: {
                            Image(systemName: "forward")
                                .foregroundColor(Color.accentColor)
                        })
                        .frame(width: 48.0, height: 48.0)
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        .cornerRadius(10.0, corners: [.bottomRight, .topRight])
                    }
                }
                .padding(.bottom, settingsModel.debugMode == true ? 96.0 : 8.0)
            }
            .padding()
            
            if $showDetailPanel.wrappedValue == true {
                ZStack {
                    if let index = multimediaObjectData.activeTourObjectIndex {
                        if let objects = multimediaObjectData.activeTour?.multimediaObjects {
                            let multimediaObjectOptional = multimediaObjectData.getMultimediaObject(id: objects[index])
                            
                            if let multimediaObject = multimediaObjectOptional {
                                VStack(spacing: 0) {
                                    List {
                                        if player != nil {
                                            VideoPlayer(player: player)
                                                .frame(width: 320, height: 180, alignment: .center)
                                                .cornerRadius(5, corners: [.allCorners])
                                                .onDisappear {
                                                    player?.pause()
                                                }
                                        } else if detailImage != nil {
                                            detailImage?
                                                .resizable()
                                                .zIndex(1)
                                                .cornerRadius(5, corners: [.allCorners])
                                                .aspectRatio(contentMode: .fill)
                                                .clipped()
                                        } else {
                                            ProgressView()
                                                .frame(width: 320, height: 180, alignment: .center)
                                                .background(Color(UIColor.lightGray))
                                                .cornerRadius(5, corners: [.allCorners])
                                        }
                                        
                                        if multimediaObject.type == .text {
                                            HStack{
                                                Text(multimediaObject.data ?? "")
                                                Spacer()
                                            }
                                        }
                                        if multimediaObject.source != nil {
                                            Section(header: Text("Source")) {
                                                HStack{
                                                    Text(multimediaObject.source ?? "")
                                                    Spacer()
                                                }
                                            }
                                        }
                                        if multimediaObject.author != nil {
                                            Section(header: Text("Author")) {
                                                HStack{
                                                    Text(multimediaObject.author ?? "")
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .scrollContentBackground(.hidden)
                                .padding()
                                .padding(.top, 32.0)
                                .onAppear(perform: {
                                    loadFile(multimediaObject: multimediaObject)
                                })
                            }
                        }
                    }
                    
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                $showDetailPanel.wrappedValue.toggle()
                            }, label: {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Color.accentColor)
                            })
                            .frame(width: 48.0, height: 48.0)
                        }
                        Spacer()
                    }
                }
                .frame(width: 340, height: 480)
                .background(Color(UIColor.systemBackground).opacity(0.95))
                .cornerRadius(10.0, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                .offset(x: 0.0, y: 40)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onChange(of: locationManagerModel.location) { oldLocation, newLocation in
            newLocationUpdate(newLocation: newLocation)
        }
        .onAppear(perform: {
            initArView()
        })
    }
}

struct AR_Previews: PreviewProvider {
    static var previews: some View {
        ARTab(selectedTab: .constant(ContentView.Tab.ar))
            .environmentObject(MultimediaObjectData())
    }
}

extension ARTab {
    
    func initArView() {
        if let activeIndex = multimediaObjectData.activeTourObjectIndex {
            if let activeTour = multimediaObjectData.activeTour {
                let multimediaObject = multimediaObjectData.getMultimediaObject(id: activeTour.multimediaObjects![activeIndex])
                navigationObject = multimediaObject
                if let multimediaObject = multimediaObject {
                    multimediaObjectData.getFileForMultimediaObject(id: multimediaObject.id!) { filePath, error in
                        loadImageNodes(object: multimediaObject, filePath: filePath)
                        loadRoute(object: multimediaObject)
                    }
                }
            }
        }
    }
    
    func newIndexUpdate(newIndex: Int?) {
        if let newIndex = newIndex {
            showDetailPanel = false
            player?.pause()
            player = nil
            detailImage = nil
            
            nodes.removeAll()
            
            if let objects = multimediaObjectData.activeTour?.multimediaObjects {
                let multimediaObjectOptional = multimediaObjectData.getMultimediaObject(id: objects[newIndex])
                
                if let multimediaObject = multimediaObjectOptional {
                    multimediaObjectData.getFileForMultimediaObject(id: multimediaObject.id!) { filePath, error in
                        navigationObject = multimediaObject
                        loadImageNodes(object: multimediaObject, filePath: filePath)
                        if !directionsRequestSent {
                            loadRoute(object: multimediaObject)
                        }
                        if multimediaObject.position == nil || multimediaObject.position?.lat == nil || multimediaObject.position?.lng == nil {
                            $showDetailPanel.wrappedValue.toggle()
                        }
                    }
                }
            }
            
        }
    }
    
    func newLocationUpdate(newLocation: CLLocation?) {
        if let newLocation = newLocation {
            if newLocation.distance(from: currLocation) >= 50.0 {
                currLocation = newLocation
            }
        }
    }
    
    func loadFile(multimediaObject: MultimediaObjectResponse) {
        if multimediaObject.type != .text {
            multimediaObjectData.getFileForMultimediaObject(id: multimediaObject.id!) { (filePath, error) in
                if filePath != nil {
                    switch multimediaObject.type {
                        case .image:
                            detailImage = Image(uiImage: UIImage(contentsOfFile: filePath!)!)
                            
                        case .video:
                            player = AVPlayer(url: URL(filePath: filePath!))
                            player?.play()
                            
                        case .audio:
                            player = AVPlayer(url: URL(filePath: filePath!))
                            player?.play()
                            
                        default:
                            return
                    }
                }
            }
        }
    }
    
    func previousTourItem() {
        if let index = multimediaObjectData.activeTourObjectIndex {
            if index - 1 >= 0 {
                directionsRequestSent = false
                multimediaObjectData.activeTourObjectIndex = index - 1
                newIndexUpdate(newIndex: index - 1)
            }
        }
    }
    
    func nextTourItem() {
        if let index = multimediaObjectData.activeTourObjectIndex {
            if let objects = multimediaObjectData.activeTour?.multimediaObjects {
                if index + 1 < objects.count {
                    directionsRequestSent = false
                    multimediaObjectData.activeTourObjectIndex = index + 1
                    newIndexUpdate(newIndex: index + 1)
                }
            }
        }
    }
    
    func abortTour() {
        navigationObject = nil
        multimediaObjectData.activeTourObjectIndex = nil
        multimediaObjectData.activeTour = nil
        nodes.removeAll()
        polyNodes.removeAll()
        polyline = nil
    }
    
    func resetArView() {
        reset += 1
    }
    
    /**
     
     */
    func loadImageNodes(object: MultimediaObjectResponse, filePath: String?) {
        if let position = object.position {
            let nodeLocation = CLLocation(latitude: position.lat, longitude: position.lng)
            let distance = locationManagerModel.location.distance(from: nodeLocation)
            
            if let type = object.type {
                if distance < 50 {
                    switch type {
                        case .image:
                        createImageNode(mmObject: object, location: nodeLocation, filePath: filePath)
                        case .video:
                        createVideoNode(mmObject: object, location: nodeLocation, filePath: filePath)
                        case .audio:
                            //$showDetailPage.wrappedValue.toggle()
                            break
                        case .text:
                            //$showDetailPage.wrappedValue.toggle()
                            break
                        default:
                            return
                    }
                    
                } else {
                    createIndicatorNode(mmObject: object, location: nodeLocation, distance: distance)
                }
            }
        }
    }
    
    /**
     
     */
    func createImageNode(mmObject: MultimediaObjectResponse, location: CLLocation, filePath: String?) {
        if let filePath = filePath {
            let imageUI = UIImage(contentsOfFile: filePath)
            var width: CGFloat = 0
            var height: CGFloat = 0
            let finalYaw = (mmObject.position?.yaw ?? 0.0) - 90.0
            let finalBearing = mmObject.position?.bearing ?? 0
            
            //        if (historicIds.contains(image.id)) {
            //            finalYaw += 90
            //            finalBearing = (finalBearing + 180) % 360
            //        }
            //
            //        if image.pitch == -1.0 {
            //            width = imageUI.size.width
            //            height = imageUI.size.height
            //            finalBearing -= 90
            //
            //        } else if image.pitch == 1.0 {
            //            width = imageUI.size.width
            //            height = imageUI.size.height
            //            finalBearing += 90
            //
            //        } else {
            //            if (!historicIds.contains(image.id)) {
            //                width = imageUI.size.height
            //                height = imageUI.size.width
            //            } else {
            //                width = imageUI.size.width
            //                height = imageUI.size.height
            //            }
            //        }
            
            if let imageUI = imageUI {
                width = imageUI.size.width
                height = imageUI.size.height
            }
            
            let scnPlane = SCNPlane(width: width*0.0008, height: height*0.0008)
            let imageNode = SCNNode(geometry: scnPlane)
            imageNode.geometry?.firstMaterial?.diffuse.contents = imageUI
            imageNode.geometry?.firstMaterial?.isDoubleSided = true
            
            imageNode.worldPosition = translateNode(location, altitude: 0.0)
            
            let currentOrientation = GLKQuaternionMake(imageNode.orientation.x, imageNode.orientation.y, imageNode.orientation.z, imageNode.orientation.w)
            let bearingRotation = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-Float(finalBearing)), 0, 1, 0)
            let yawRotation = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(finalYaw), 0, 0, 1)
            let finalOrientation = GLKQuaternionMultiply(GLKQuaternionMultiply(currentOrientation, bearingRotation), yawRotation)
            imageNode.orientation = SCNQuaternion(finalOrientation.x, finalOrientation.y, finalOrientation.z, finalOrientation.w)
            
            nodes.append(imageNode)
        }
    }
    
    func createVideoNode(mmObject: MultimediaObjectResponse, location: CLLocation, filePath: String?) {
        if let filePath = filePath {
            let player = AVPlayer(url: URL(filePath: filePath))
            
            let videoAsset = AVURLAsset(url : URL(filePath: filePath))
            let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first

            let videoNode = SKVideoNode(avPlayer: player)
            videoNode.play()
            let videoScene = SKScene(size: CGSize(width: videoAssetTrack?.naturalSize.width ?? 8, height: videoAssetTrack?.naturalSize.height ?? 4.5))
            videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            videoNode.yScale = -1.0
            videoScene.addChild(videoNode)
            
            let plane = SCNPlane(width: videoScene.size.width/100, height: videoScene.size.width/100)
            plane.firstMaterial?.diffuse.contents = videoScene
            let planeNode = SCNNode(geometry: plane)
            
            planeNode.geometry?.firstMaterial?.diffuse.contents = videoScene
            planeNode.geometry?.firstMaterial?.isDoubleSided = true
            
            planeNode.worldPosition = translateNode(location, altitude: 0.0)
            
//                let currentOrientation = GLKQuaternionMake(planeNode.orientation.x, planeNode.orientation.y, planeNode.orientation.z, planeNode.orientation.w)
//                let bearingRotation = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-Float(finalBearing)), 0, 1, 0)
//                let yawRotation = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(finalYaw), 0, 0, 1)
//                let finalOrientation = GLKQuaternionMultiply(GLKQuaternionMultiply(currentOrientation, bearingRotation), yawRotation)
//                planeNode.orientation = SCNQuaternion(finalOrientation.x, finalOrientation.y, finalOrientation.z, finalOrientation.w)
            
            nodes.append(planeNode)
        }
        
    }
    
    /**
     
     */
    func createIndicatorNode(mmObject: MultimediaObjectResponse, location: CLLocation, distance: CLLocationDistance) {
        
        let skScene = SKScene(size: CGSize(width: 150, height: 100))
        skScene.backgroundColor = UIColor.clear

        let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 150, height: 100), cornerRadius: 10)
        rectangle.fillColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        rectangle.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        rectangle.lineWidth = 1
        rectangle.alpha = 1.0
        let labelNode = SKLabelNode(text: String(Int(distance)) + "m")
        labelNode.fontSize = 32
        labelNode.position = CGPoint(x:75, y:60)
        labelNode.zRotation = CGFloat(GLKMathDegreesToRadians(180))
        skScene.addChild(rectangle)
        skScene.addChild(labelNode)
        
        let scnPlane = SCNPlane(width: 3.0, height: 2.0)
        let imageNode = SCNNode(geometry: scnPlane)
        imageNode.geometry?.firstMaterial?.diffuse.contents = skScene
        imageNode.geometry?.firstMaterial?.isDoubleSided = true
        
        let worldPos = translateNodeWithDistance(location, altitude: 0.0, distance: 10.0)
        imageNode.worldPosition = worldPos
        
        imageNode.pivot = SCNMatrix4MakeRotation(.pi, 0, 1, 0);
        let yFreeConstraint = SCNBillboardConstraint()
        imageNode.constraints = [yFreeConstraint]
        
        nodes.append(imageNode)
    }
    
    /**
     
     */
    func loadRoute(object: MultimediaObjectResponse) {
        print("loading route...")
        if let position = object.position {
            print("starting request...")
            var tempNodes: [SCNNode] = []
            let request = MKDirections.Request()
            request.transportType = .walking
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationManager().location!.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng)))
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            directionsRequestSent = true
            directions.calculate { response, error in
                guard let mapRoute = response?.routes.first else {
                    print(error ?? "")
                    return
                }
                
                defer { print("directions request finished") }
                
                polyline = mapRoute.polyline
                let points = mapRoute.polyline.points()
                
                let startLineNode = SCNGeometry.cylinderLine(from: translateNode(locationManagerModel.location, altitude: -2.0), to: translateNode(CLLocation(coordinate: points[0].coordinate), altitude: -2.0), segments: 48)
                tempNodes.append(startLineNode)
                
                for i in 0 ..< mapRoute.polyline.pointCount - 1 {
                    let currentLocation = CLLocation(coordinate: points[i].coordinate)
                    let nextLocation = CLLocation(coordinate: points[i + 1].coordinate)
                    
                    let cylinderLineNode = SCNGeometry.cylinderLine(from: translateNode(currentLocation, altitude: -2.0), to: translateNode(nextLocation, altitude: -2.0), segments: 48)
                    
                    tempNodes.append(cylinderLineNode)
                    let startPointSphere = addPolyPointNode(point: currentLocation, color: .green)
                    tempNodes.append(startPointSphere)
                }
                
                let endSphere = addPolyPointNode(point: CLLocation(coordinate: points[mapRoute.polyline.pointCount-1].coordinate), color: .green)
                tempNodes.append(endSphere)
                
                let endLineNode = SCNGeometry.cylinderLine(from: translateNode(CLLocation(coordinate: points[mapRoute.polyline.pointCount-1].coordinate), altitude: -2.0), to: translateNode(CLLocation(coordinate: CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng)), altitude: -2.0), segments: 48)
                tempNodes.append(endLineNode)
                polyNodes.removeAll()
                polyNodes.append(contentsOf: tempNodes)
            }
        }
    }
    
    /**
     
     */
    func addPolyPointNode(point: CLLocation, color: UIColor) -> SCNNode {
        let scnSphere = SCNSphere(radius: 1.0)
        scnSphere.firstMaterial?.diffuse.contents = color
        let polyNode = SCNNode(geometry: scnSphere)
        
        polyNode.worldPosition = translateNode(point, altitude: -2.0)
        return polyNode
    }
    
    /**
     
     */
    func translateNode (_ location: CLLocation, altitude: CLLocationDistance) -> SCNVector3 {
        let currCameraTransform = arDelegate.cameraTransform ?? matrix_identity_float4x4
        let locationTransform = GeometryUtils.transformMatrix(currCameraTransform, locationManagerModel.location, location)
        return SCNVector3Make(locationTransform.columns.3.x, locationTransform.columns.3.y + Float(altitude), locationTransform.columns.3.z)
    }
    
    func translateNodeWithDistance (_ location: CLLocation, altitude: CLLocationDistance, distance: Double) -> SCNVector3 {
        let currCameraTransform = arDelegate.cameraTransform ?? matrix_identity_float4x4
        let locationTransform = GeometryUtils.transformMatrixWithDistance(currCameraTransform, locationManagerModel.location, location, distance)
        return SCNVector3Make(locationTransform.columns.3.x, locationTransform.columns.3.y + Float(altitude), locationTransform.columns.3.z)
    }
}

extension SCNGeometry {
    
    /**
     
     */
    class func cylinderLine(from: SCNVector3, to: SCNVector3, segments: Int) -> SCNNode {
        let x1 = from.x
        let x2 = to.x
        let y1 = from.y
        let y2 = to.y
        let z1 = from.z
        let z2 = to.z
        
        let distance =  sqrtf((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1) + (z2-z1) * (z2-z1))
        let cylinder = SCNCylinder(radius: 0.2, height: CGFloat(distance))
        cylinder.radialSegmentCount = segments
        cylinder.firstMaterial?.diffuse.contents = UIColor.blue
        let lineNode = SCNNode(geometry: cylinder)
        lineNode.position = SCNVector3(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2, z: (from.z + to.z) / 2)
        lineNode.eulerAngles = SCNVector3(Float.pi / 2, acos((to.z-from.z)/distance), atan2((to.y-from.y),(to.x-from.x)))
        
        return lineNode
    }
}

extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(coordinate: coordinate, altitude: 2.0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    }
    
    func coordinateWithBearing(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        let phi = Double(GLKMathDegreesToRadians(Float(self.coordinate.latitude)))
        let lambda = Double(GLKMathDegreesToRadians(Float(self.coordinate.longitude)))
        let theta = Double(GLKMathDegreesToRadians(Float(bearing)))
        
        let sigma = distanceMeters / self.earthRadiusMeters()
        let a = sin(phi) * cos(sigma)
        let b = cos(phi) * sin(sigma) * cos(theta)
        let phi2 = asin(a + b)
        let c = sin(theta) * sin(sigma) * cos(phi)
        let d = cos(sigma) - sin(phi) * sin(phi2)
        let lambda2 = lambda + atan2(c, d)
        
        let result = CLLocationCoordinate2D(latitude: Double(GLKMathDegreesToRadians(Float(phi2))), longitude: Double(GLKMathDegreesToRadians(Float(lambda2))))
        return result
    }
    
    func earthRadiusMeters() -> Double {
        let WGS84EquatorialRadius  = 6_378_137.0
        let WGS84PolarRadius = 6_356_752.3
        
        let a = WGS84EquatorialRadius
        let b = WGS84PolarRadius
        let phi = Double(GLKMathDegreesToRadians(Float(self.coordinate.latitude)))
        
        let c = pow(a * a * cos(phi), 2)
        let d = pow(b * b * sin(phi), 2)
        let numerator = c + d
        
        let e = pow(a * cos(phi), 2)
        let f = pow(b * sin(phi), 2)
        let denominator = e + f
        
        let radius: Double = sqrt(numerator/denominator)
        print(radius)
        return radius
    }
}

