//
//  ARTab.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import SwiftUI
import ARKit
import MapKit
import OpenAPIClient

/**
 
 */
struct ARTab: View {
    
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var arDelegate = ARDelegate()
    @State var redrawImages: Bool = false
    @State private var applyAnnotations: Bool = true
    @State var currLocation: CLLocation = CLLocation()
    @State var navigationObject: MultimediaObjectResponse? = nil
    
    var body: some View {
        ZStack {
            Color.black
            if selectedTab == .ar {
                ARViewRepresentable(arDelegate: arDelegate, redrawImages: $redrawImages)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .padding()
                    .foregroundColor(Color.accentColor)
            }
            
            VStack {
                HStack {
                    Spacer()
                    RadarView(navigationImage: $navigationObject, redrawImages: $redrawImages, applyAnnotations: $applyAnnotations)
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
                        }
                        .offset(x: 0.0, y: 40)
                }
                Spacer()
                HStack (alignment: .center) {
                    if multimediaObjectData.activeTourObjectIndex != nil {
                        Button(action: {
                            arDelegate.removeAllPolyNodes()
                            $redrawImages.wrappedValue.toggle()
                            multimediaObjectData.activeTourObjectIndex = nil
                            multimediaObjectData.activeTour = nil
                        }, label: {
                            Image(systemName: "xmark")
                                .padding()
                                .foregroundColor(Color.accentColor)
                        })
                        .frame(width: 48.0, height: 48.0)
                        .background(Color(UIColor.systemBackground).opacity(0.95))
                        .cornerRadius(10.0, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight])
                    }
                    Spacer()
                    Text(arDelegate.message)
                        .foregroundColor(Color.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    Spacer()
                    Button(action: {
                        arDelegate.reset()
                        $redrawImages.wrappedValue.toggle()
                    }, label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .padding()
                            .foregroundColor(Color.accentColor)
                    })
                    .frame(width: 48.0, height: 48.0)
                    .background(Color(UIColor.systemBackground).opacity(0.95))
                    .cornerRadius(10.0, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight])
                }
            }
            .padding()
            
        }
        .edgesIgnoringSafeArea(.top)
        .onChange(of: locationManagerModel.location, perform: { newLocation in
            if newLocation.distance(from: currLocation) >= 5.0 {
                currLocation = newLocation
                $redrawImages.wrappedValue.toggle()
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
