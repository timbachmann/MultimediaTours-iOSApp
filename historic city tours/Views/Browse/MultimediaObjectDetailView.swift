//
//  MultimediaObjectDetailView.swift
//  historic city tours
//
//  Created by Tim Bachmann on 06.05.2024.
//

import SwiftUI
import OpenAPIClient
import AVKit

struct MultimediaObjectDetailView: View {
    @State var multimediaObject: MultimediaObjectResponse
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @State private var detailImage: Image?
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack{
            if player != nil {
                VideoPlayer(player: player)
                    .frame(width: 320, height: 180, alignment: .center)
                    .onDisappear {
                        player?.pause()
                    }
            }
            List {
                if detailImage != nil {
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
                }
                if multimediaObject.type == .text {
                    HStack{
                        Text($multimediaObject.data.wrappedValue ?? "")
                        Spacer()
                    }
                }
                if multimediaObject.position != nil {
                    Section(header: Text("Position")) {
                        HStack{
                            Text("\($multimediaObject.position.wrappedValue?.lat ?? 0.0), \($multimediaObject.position.wrappedValue?.lng ?? 0.0)")
                            Spacer()
                        }
                    }
                }
                Section(header: Text("Source")) {
                    HStack{
                        Text($multimediaObject.source.wrappedValue ?? "")
                        Spacer()
                    }
                }
                Section(header: Text("Author")) {
                    HStack{
                        Text($multimediaObject.author.wrappedValue ?? "")
                        Spacer()
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
}

