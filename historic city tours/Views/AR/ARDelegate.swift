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
    @Published var message: String = "starting AR"
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
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panOnARView))
//        arView.addGestureRecognizer(panGesture)
    }
    
    /**
     
     */
    @objc func panOnARView(sender: UIPanGestureRecognizer) {
        guard let arView = arView else { return }
        let location = sender.location(in: arView)
        switch sender.state {
        case .began:
            if let node = nodeAtLocation(location) {
                trackedNode = node
            }
        case .changed:
            if let node = trackedNode {
                if let result = raycastResult(fromLocation: location) {
                    moveNode(node, raycastResult:result)
                }
            }
        default:
            ()
        }
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
    private func moveNode(_ node:SCNNode, raycastResult:ARRaycastResult) {
        node.simdWorldTransform = raycastResult.worldTransform
        node.rotation = SCNVector4Make(0, 0, 1, .pi / -2)
        nodesUpdated()
    }
    
    /**
     
     */
    private func nodeAtLocation(_ location:CGPoint) -> SCNNode? {
        guard let arView = arView else { return nil }
        let result = arView.hitTest(location, options: nil)
        return result.first?.node
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
            message = "\(nodes.count) AR objects placed"
        }
        else {
            message = "Node not placed"
        }
    }
    
    /**
     
     */
    private func raycastResult(fromLocation location: CGPoint) -> ARRaycastResult? {
        guard let arView = arView,
              let query = arView.raycastQuery(from: location,
                                        allowing: .existingPlaneGeometry,
                                        alignment: .horizontal) else { return nil }
        let results = arView.session.raycast(query)
        return results.first
    }
    
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
}
