//
//  ARSCNViewDelegate.swift
//  ArkitDemo
//
//  Created by Siddhesh on 24/11/21.
//

import Foundation
import ARKit

extension ARDesignViewer: ARSCNViewDelegate , ARSessionDelegate{
    /*
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     print("placin object")
     print("anchor name",anchor.name)
     if(anchor.name == self.nodeName){
     let fileNameComponents = self.modelName.split(separator: ".").map { String($0) }
     let fileExt = fileNameComponents.last
     self.nodeName = fileNameComponents.first ?? "theNameOfTheParentNodeOfTheObject"
     var scnFileName = self.modelName
     if self.modelName.count > 4 && self.modelName.contains(".scn"){
     scnFileName.removeLast(4)
     }
     
     if fileExt == "scn"{
     guard let scnScene = SCNScene(named: self.modelName), let scnSceneNode = scnScene.rootNode.childNode(withName: scnFileName, recursively: true) else { return SCNNode()}
     scnSceneNode.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
     scnSceneNode.name = self.nodeName
     scnSceneNode.categoryBitMask = BodyType.ObjectModel.rawValue
     scnSceneNode.enumerateChildNodes { (node, _) in
     node.categoryBitMask = BodyType.ObjectModel.rawValue
     }
     return scnSceneNode
     
     }else if fileExt == "dae"{
     guard let modelScene = SCNScene(named: self.modelName) else { return SCNNode()}
     let modelNode = SCNNode()
     let modelSceneChildNodes = modelScene.rootNode.childNodes
     for childNode in modelSceneChildNodes {
     modelNode.addChildNode(childNode)
     }
     modelNode.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
     modelNode.name = self.nodeName
     modelNode.categoryBitMask = BodyType.ObjectModel.rawValue
     modelNode.enumerateChildNodes { (node, _) in
     node.categoryBitMask = BodyType.ObjectModel.rawValue
     }
     let scale = 0.009
     modelNode.scale = SCNVector3(scale, scale, scale)
     return modelNode
     }else if fileExt == "usdz"{
     print("getting file path")
     guard let urlPath = Bundle.main.url(forResource: self.nodeName, withExtension: "usdz") else {
     print("getting file path failed",self.nodeName)
     return SCNNode()
     }
     let mdlAsset = MDLAsset(url: urlPath)
     mdlAsset.loadTextures()
     let asset = mdlAsset.object(at: 0) // extract first object
     let assetNode = SCNNode(mdlObject: asset)
     assetNode.worldPosition = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
     //assetNode.scale = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
     assetNode.name = self.nodeName
     assetNode.categoryBitMask = BodyType.ObjectModel.rawValue
     assetNode.enumerateChildNodes { (node, _) in
     node.categoryBitMask = BodyType.ObjectModel.rawValue
     }
     print("adding usdz node")
     addedNodes.append(assetNode)
     if !addedNodes.isEmpty{
     DispatchQueue.main.async {
     self.addBtn.isHidden = true
     }
     }
     return assetNode
     }else{
     print("invalid format")
     }
     }
     return SCNNode()
     }
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: false)
        }
    }
    
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            print("ARSession camera.trackingState is",camera.trackingState)
        case .limited(_):
            print("ARSession camera.trackingState is",camera.trackingState)
        case .normal:
            print("ARSession camera.trackingState is",camera.trackingState)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        print("ARSession didFailWithError",errorMessage)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("sessionWasInterrupted",session)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("sessionInterruptionEnded",session)
        resetARSession()
    }
    
    /*
     Allow the session to attempt to resume after an interruption.
     This process may not succeed, so the app must be prepared
     to reset the session if the relocalizing status continues
     for a long time.
     */
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}
