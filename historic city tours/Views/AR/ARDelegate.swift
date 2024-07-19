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
    private var message: String = "starting AR"
    @Published var cameraTransform: simd_float4x4? = nil
    private var arView: ARSCNView?
    private var nodes: [SCNNode] = []
    private var polyNodes: [SCNNode] = []
    private var trackedNode:SCNNode?
    
    /**
     
     */
    func setARView(_ arView: ARSCNView) {
        self.arView = arView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
        
        arView.delegate = self
        arView.scene = SCNScene()
    }
    
    /**
     
     */
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
    func reset() {
        if arView != nil {
            arView?.session.pause()
            arView?.scene.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
            let configuration = ARWorldTrackingConfiguration()
            configuration.worldAlignment = .gravityAndHeading
            configuration.planeDetection = .horizontal
            arView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    /**
     
     */
    func placeNode(node: SCNNode) {
        nodes.append(node)
        arView?.scene.rootNode.addChildNode(node)
        nodesUpdated()
    }
    
    /**
     
     */
    func placePolyNode(polyNode: SCNNode) {
        polyNodes.append(polyNode)
        arView?.scene.rootNode.addChildNode(polyNode)
    }
    
    /**
     
     */
    func nodesUpdated() {
        if nodes.count >= 1 {
            message = "\(nodes.count) AR object(s) placed"
        }
        else {
            message = "Node not placed..."
        }
    }
    
    /**
     
     */
//    private func raycastResult(fromLocation location: CGPoint) -> ARRaycastResult? {
//        guard let arView = arView,
//              let query = arView.raycastQuery(from: location,
//                                        allowing: .existingPlaneGeometry,
//                                        alignment: .horizontal) else { return nil }
//        let results = arView.session.raycast(query)
//        return results.first
//    }
    
    /**
     
     */
    func removeNode(node:SCNNode) {
        node.removeFromParentNode()
        nodes.removeAll(where: { $0 == node })
    }
    
    /**
     
     */
    func removeAllNodes() {
        for node in nodes {
            removeNode(node: node)
        }
    }
    
    /**
     
     */
    func removePolyNode(node: SCNNode) {
        node.removeFromParentNode()
        polyNodes.removeAll(where: { $0 == node })
    }
    
    /**
     
     */
    func removeAllPolyNodes() {
        for node in polyNodes {
            removePolyNode(node: node)
        }
    }
    
    func getMessage() -> String {
        return message
    }
}
