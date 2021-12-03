//
//  AppUtils.swift
//  ArkitDemo
//
//  Created by Siddhesh on 19/11/21.
//

import Foundation
import ARKit

class AppUtils{
    
    static func getParentNodeOf(_ nodeFound: SCNNode?, _ nodeName: String) -> SCNNode? {
        if let node = nodeFound {
            if node.name == nodeName {
                return node
            } else if let parent = node.parent {
                return getParentNodeOf(parent,nodeName)
            }
        }
        return nil
    }
    
    static func doHitTestWithARRaycast(_ position: CGPoint,
                                       in sceneView: ARSCNView,
                                       objectPos: SIMD3<Float>?,
                                       infinitePlane: Bool = false) -> (position: SIMD3<Float>?, planeAnchor: ARPlaneAnchor?, hitTestResult: [ARRaycastResult]? ,hitAPlane: Bool) {
        
        var target:ARRaycastQuery.Target = .existingPlaneGeometry
        if infinitePlane{
            target = .existingPlaneInfinite
        }
        
        
        guard let planeHitTestResults = sceneView.raycastQuery(from: position, allowing: target, alignment: .any) else{
            return (nil, nil, nil, false)
        }
        
        let results: [ARRaycastResult] = sceneView.session.raycast(planeHitTestResults)
        if let result = results.first {
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, results,true)
        }
        
        return (nil, nil, nil, false)
    }
}
