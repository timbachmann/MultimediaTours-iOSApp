//
//  MultimediaObjectDetailView.swift
//  historic city tours
//
//  Created by Tim Bachmann on 06.05.2024.
//

import SwiftUI
import OpenAPIClient
import AVKit
import MapKit

struct MultimediaObjectDetailView: View {
    @Binding var selectedTab: ContentView.Tab
    @State var multimediaObject: MultimediaObjectResponse
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @State private var detailImage: Image?
    @State private var player: AVPlayer?
    @State private var mapType: MKMapType = .standard
    @State private var zoomOnLocation: Bool = false
    @State private var changeMapType: Bool = false
    @State private var annotations: [CustomPointAnnotation] = []
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
    
    var body: some View {
        VStack{
            List {
                if player != nil {
                    VideoPlayer(player: player)
                        .frame(width: 320, height: 180, alignment: .center)
                        .onDisappear {
                            player?.pause()
                        }
                } else if detailImage != nil {
                    HStack{
                        Spacer()
                        detailImage?
                            .resizable()
                            .zIndex(1)
                            .cornerRadius(5, corners: [.allCorners])
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                        
                        Spacer()
                    }.padding([.top, .bottom], 14.0)
                } else {
                    HStack{
                        Spacer()
                        Image(systemName: "photo")
                            .font(.system(size: 250))
                            .frame(height: 220)
                            .zIndex(1)
                            .cornerRadius(5, corners: [.allCorners])
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                        
                        Spacer()
                    }
                    .padding([.top, .bottom], 14.0)
                    .redacted(reason: .placeholder)
                }
                if multimediaObject.type == .text {
                    HStack{
                        Text($multimediaObject.data.wrappedValue ?? "")
                        Spacer()
                    }
                }
                if multimediaObject.position != nil {
                    Section(header: Text("Position")) {
                        MapViewObjectDetail(mmObject: $multimediaObject, selectedTab: $selectedTab,  zoomOnLocation: $zoomOnLocation, changeMapType: $changeMapType, annotations: $annotations, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
                                    .frame(height: 200)
                    }
                }
                if $multimediaObject.source.wrappedValue != nil {
                    Section(header: Text("Source")) {
                        HStack{
                            Text($multimediaObject.source.wrappedValue ?? "")
                            Spacer()
                        }
                    }
                }
                if $multimediaObject.author.wrappedValue != nil {
                    Section(header: Text("Author")) {
                        HStack{
                            Text($multimediaObject.author.wrappedValue ?? "")
                            Spacer()
                        }
                    }
                }
                
                if $multimediaObject.tags.wrappedValue?.count != 0 {
                    Section(header: Text("Tags")) {
                        HStack{
                            ForEach($multimediaObject.tags.wrappedValue ?? [], id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 4.0)
                                    .padding(.vertical, 2.0)
                                    .font(.system(size: 12))
                                    .background(Color.tag)
                                    .cornerRadius(3.0, corners: .allCorners)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationTitle($multimediaObject.title.wrappedValue ?? "Tour")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            loadFile()
        })
    }
}

extension MultimediaObjectDetailView {
    
    func loadFile() {
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
        
        if let position = $multimediaObject.wrappedValue.position {
            let annotation = CustomPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: position.lat, longitude: position.lng), title: $multimediaObject.wrappedValue.title!, subtitle: $multimediaObject.wrappedValue.source!, id: $multimediaObject.wrappedValue.id!)
            
            annotations.removeAll()
            annotations.append(annotation)
        }
    }
}

