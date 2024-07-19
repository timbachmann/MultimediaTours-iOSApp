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

/**
 
 */
struct ARTab: View {
    
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var settingsModel: SettingsModel
    
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var arDelegate = ARDelegate()
    
    @State private var detailImage: Image?
    @State private var player: AVPlayer?
    @State var redrawImages: Bool = false
    @State var redrawImagesMap: Bool = false
    @State var showDetailPanel: Bool = false
    @State private var applyAnnotations: Bool = true
    @State var currLocation: CLLocation = CLLocation()
    @State var navigationObject: MultimediaObjectResponse? = nil
    
    var body: some View {
        ZStack {
            Color.black
            if selectedTab == .ar {
                ARViewRepresentable(arDelegate: arDelegate, redrawImages: $redrawImages, showDetailPage: $showDetailPanel)
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
                        RadarView(navigationImage: $navigationObject, redrawImages: $redrawImagesMap, applyAnnotations: $applyAnnotations)
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
                            .onChange(of: multimediaObjectData.activeTourObjectIndex) { tag in
                                applyAnnotations = true
                                redrawImagesMap = true
                            }
                            .offset(x: 0.0, y: 40)
                            .padding(.bottom, 64.0)
                        
                        VStack(spacing: 0) {
                            if multimediaObjectData.activeTourObjectIndex != nil {
                                Button(action: {
                                    $navigationObject.wrappedValue = nil
                                    multimediaObjectData.activeTourObjectIndex = nil
                                    multimediaObjectData.activeTour = nil
                                    arDelegate.removeAllPolyNodes()
                                    if $redrawImages.wrappedValue == false {
                                        $redrawImages.wrappedValue = true
                                    }
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
                                
                                Button(action: {
                                    arDelegate.reset()
                                    if $redrawImages.wrappedValue == false {
                                        $redrawImages.wrappedValue = true
                                    }
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
                        Button(action: {
                            if let index = multimediaObjectData.activeTourObjectIndex {
                                if index - 1 >= 0 {
                                    updateNavigationItem(newValue: index - 1)
                                }
                            }
                        }, label: {
                            Image(systemName: "backward")
                                .foregroundColor(Color.accentColor)
                        })
                        .frame(width: 48.0, height: 48.0)
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        .cornerRadius(10.0, corners: [.topLeft, .bottomLeft])
                        .disabled(redrawImages)
                        
                        Divider()
                            .frame(width: 1.0, height: 48.0)
                            .background(Color(UIColor.systemBackground).opacity(0.95))
                        
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
                        
                        Button(action: {
                            if let index = multimediaObjectData.activeTourObjectIndex {
                                if let objects = multimediaObjectData.activeTour?.multimediaObjects {
                                    if index + 1 < objects.count {
                                        updateNavigationItem(newValue: index + 1)
                                    }
                                }
                            }
                        }, label: {
                            Image(systemName: "forward")
                                .foregroundColor(Color.accentColor)
                        })
                        .frame(width: 48.0, height: 48.0)
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        .cornerRadius(10.0, corners: [.bottomRight, .topRight])
                        .disabled(redrawImages)
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
                                    if player != nil {
                                        VideoPlayer(player: player)
                                            .frame(width: 320, height: 180, alignment: .center)
                                            .onDisappear {
                                                player?.pause()
                                            }
                                    }
                                    List {
                                        if detailImage != nil {
                                            detailImage?
                                                .resizable()
                                                .zIndex(1)
                                                .cornerRadius(5, corners: [.allCorners])
                                                .aspectRatio(contentMode: .fill)
                                                .clipped()
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
        .onChange(of: locationManagerModel.location, perform: { newLocation in
            if newLocation.distance(from: currLocation) >= 50.0 {
                currLocation = newLocation
                if $redrawImages.wrappedValue == false {
                    $redrawImages.wrappedValue = true
                }
            }
        })
        .onAppear(perform: {
            if let activeIndex = multimediaObjectData.activeTourObjectIndex {
                if let activeTour = multimediaObjectData.activeTour {
                    navigationObject = multimediaObjectData.getMultimediaObject(id: activeTour.multimediaObjects![activeIndex])
                }
            }
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
    func loadFile(multimediaObject: MultimediaObjectResponse) {
        if multimediaObject.type != .text {
            multimediaObjectData.getFileForMultimediaObject(id: multimediaObject.id!, type: multimediaObject.type!) { (filePath, error) in
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
    
    func updateNavigationItem(newValue: Int) {
        $showDetailPanel.wrappedValue = false
        player?.pause()
        $player.wrappedValue = nil
        $detailImage.wrappedValue = nil
        
        $navigationObject.wrappedValue = nil
        multimediaObjectData.activeTourObjectIndex = nil
        arDelegate.removeAllPolyNodes()
        $redrawImages.wrappedValue = true
        
        $multimediaObjectData.activeTourObjectIndex.wrappedValue = newValue
        
        if let index = multimediaObjectData.activeTourObjectIndex {
            if let objects = multimediaObjectData.activeTour?.multimediaObjects {
                let multimediaObjectOptional = multimediaObjectData.getMultimediaObject(id: objects[index])
                
                if let multimediaObject = multimediaObjectOptional {
                    $navigationObject.wrappedValue = multimediaObject
                    $redrawImages.wrappedValue = true
                    
                    if multimediaObject.position == nil || multimediaObject.position?.lat == nil || multimediaObject.position?.lng == nil {
                        $showDetailPanel.wrappedValue.toggle()
                    }
                }
            }
        }
        
    }
}
