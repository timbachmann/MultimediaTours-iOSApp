//
//  ARDelegate.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import Foundation
import ARKit
import UIKit

/**
 
 */
class ARDelegate: NSObject, ARSCNViewDelegate, ObservableObject {
    private var message: String = "Starting AR"
    @Published var cameraTransform: simd_float4x4? = nil
    var arView: ARSCNView?
    var nodes: [SCNNode] = []
    var polyNodes: [SCNNode] = []
    var currLocation: CLLocation = CLLocation()
    var reset: Int = 0
    
    
    func setARView(_ arView: ARSCNView) {
        self.arView = arView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        arView.delegate = self
        arView.scene = SCNScene()
    }
    
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("camera did change \(camera.trackingState)")
        switch camera.trackingState {
        case .limited(_):
            message = "Tracking limited"
        case .normal:
            message =  "Tracking ready"
        case .notAvailable:
            message = "Tracking not available"
        }
    }
    
    /**
     
     */
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        cameraTransform = frame.camera.transform
    }
    
    /**
     
     */
    func reset(view: ARSCNView) {
        view.session.pause()
        view.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = .horizontal
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        updateNodes(view: view)
        updatePolyNodes(view: view)
    }
    
    
    func placeNode(node: SCNNode, view: ARSCNView) {
        view.scene.rootNode.addChildNode(node)
    }
    
    
    func updateNodes(view: ARSCNView) {
        view.scene.rootNode.enumerateChildNodes { (existingNode, _) in
            if !polyNodes.contains(where: { $0 == existingNode}) {
                existingNode.removeFromParentNode()
            }
        }
        for newNode in nodes {
            placeNode(node: newNode, view: view)
        }
    }
    
    
    func updatePolyNodes(view: ARSCNView) {
        view.scene.rootNode.enumerateChildNodes { (existingNode, _) in
            if !nodes.contains(where: { $0 == existingNode}) {
                existingNode.removeFromParentNode()
            }
        }
        for newPolyNode in polyNodes {
            placeNode(node: newPolyNode, view: view)
        }
    }
    
    
    func getMessage() -> String {
        return message
    }
    
    
    func setCurrLocation(newLocation: CLLocation) {
        currLocation = newLocation
    }
}
