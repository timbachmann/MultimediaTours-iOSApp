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
            .background(Color.sand)
            .scrollContentBackground(.hidden)
            Spacer()
        }
        .background(Color.sand)
        .navigationTitle($multimediaObject.title.wrappedValue ?? "Tour")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.sand, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear(perform: {
            loadFile()
        })
    }
}

extension MultimediaObjectDetailView {
    
    func loadFile() {
            switch multimediaObject.type {
                case .image:
                    FilesAPI.multimediaObjectsFileIdGet(id: multimediaObject.id!) { (response, error) in
                        let filePath = response!.path()
                        detailImage = Image(uiImage: UIImage(contentsOfFile: filePath)!)
                    }
                case .video:
                    FilesAPI.multimediaObjectsFileIdGet(id: multimediaObject.id!) { (response, error) in
                        let filePath = response!.path()
                        player = AVPlayer(url: URL(filePath: filePath))
                        player?.play()
                    }
                case .audio:
                    FilesAPI.multimediaObjectsFileIdGet(id: multimediaObject.id!) { (response, error) in
                        let filePath = response!.path()
                        player = AVPlayer(url: URL(filePath: filePath))
                        player?.play()
                    }
                default:
                    return
            
        }
    }
}

