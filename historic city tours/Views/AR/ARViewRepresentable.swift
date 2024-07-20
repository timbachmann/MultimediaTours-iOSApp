//
//  ARViewRepresentable.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import ARKit
import SwiftUI
import OpenAPIClient
import CoreMotion
import MapKit


struct ARViewRepresentable: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    
    let arDelegate: ARDelegate
    @EnvironmentObject var settingsModel: SettingsModel
    @Binding var nodes: [SCNNode]
    @Binding var polyNodes: [SCNNode]
    @Binding var currLocation: CLLocation
    
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        if settingsModel.debugMode == true {
            arView.showsStatistics = true
            arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        }
        arDelegate.setARView(arView)
        placeImageOrIndicatorNodes(view: arView)
        placePolyNodes(view: arView)
        return arView
    }
    
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if (Set(nodes) != Set(arDelegate.nodes)) {
            DispatchQueue.main.async {
                arDelegate.nodes.removeAll()
                arDelegate.nodes.append(contentsOf: nodes)
                arDelegate.updateNodes(view: uiView)
            }
        }
        
        if (Set(polyNodes) != Set(arDelegate.polyNodes)) {
            DispatchQueue.main.async {
                arDelegate.polyNodes.removeAll()
                arDelegate.polyNodes.append(contentsOf: polyNodes)
                arDelegate.updatePolyNodes(view: uiView)
            }
        }
        
        if (currLocation != arDelegate.currLocation) {
            DispatchQueue.main.async {
                arDelegate.setCurrLocation(newLocation: currLocation)
            }
        }
        
    }
    
    
    func placeImageOrIndicatorNodes(view: ARSCNView) {
        for node in nodes {
            arDelegate.placeNode(node: node, view: view)
        }
    }
    
    
    func placePolyNodes(view: ARSCNView) {
        for polyNode in polyNodes {
            arDelegate.placeNode(node: polyNode, view: view)
        }
    }
}
