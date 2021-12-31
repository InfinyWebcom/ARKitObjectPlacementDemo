//
//  3DModelViewer.swift
//  ArkitDemo
//
//  Created by Alexander John on 26/10/21.
//

import UIKit
import ARKit
import SceneKit.ModelIO

class ARDesignViewer: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    //MARK: - Class properties
    
    let configuration = ARWorldTrackingConfiguration()
    let coachingOverlay = ARCoachingOverlayView()
    let defaults = UserDefaults.standard
    
    var modelName = ""
    var nodeName = ""
    var lockObject = false
    
    var session: ARSession {
        return sceneView.session
    }
    var focusSquare = FocusSquare()
    var selectedNode: SCNNode?
    var addedNodes = [SCNNode]()
    var panGestureRecognizer = UIPanGestureRecognizer()
    var planeType:ARWorldTrackingConfiguration.PlaneDetection = [.horizontal]
    var isObjectVisible = false
    //MARK: - ViewController Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        configureLighting()
        setupCoachingOverlay()
        addGestureToSceneView()
        
        defaults.set(false, for: Settings.verticalPlane)
        defaults.set(false, for: Settings.horizontalAndVerticalPlane)
        defaults.set(false, for: Settings.lockObject)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        resetARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    
    //MARK: - @IBAction UIButton
    
    @IBAction func resetARView(_ sender: UIButton) {
        resetARSession()
    }
    
    @IBAction func settingBtnTapped(_ sender: UIButton) {
       
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        nextVC.modalPresentationStyle = .popover
        nextVC.popoverPresentationController?.sourceView = sender
        nextVC.popoverPresentationController?.permittedArrowDirections = .down
        nextVC.popoverPresentationController?.delegate = self
        nextVC.updateSession = { value in
            if value ?? false{
                if UserDefaults.standard.bool(forKey: Settings.verticalPlane.rawValue) && self.planeType != [.vertical]{
                    self.planeType = [.vertical]
                    self.updateARSession()
                }else if UserDefaults.standard.bool(forKey: Settings.horizontalAndVerticalPlane.rawValue) && self.planeType != [.horizontal, .vertical]{
                    self.planeType = [.horizontal, .vertical]
                    self.updateARSession()
                }else if self.planeType != [.horizontal]{
                    self.planeType = [.horizontal]
                    self.updateARSession()
                }
                
                self.lockObject = UserDefaults.standard.bool(forKey: Settings.lockObject.rawValue)
                
                if self.lockObject{
                    self.panGestureRecognizer.isEnabled = false
                }else{
                    self.panGestureRecognizer.isEnabled = true
                }
            }
        }
        
        self.present(nextVC, animated: true, completion: nil)
        
    }
     
    
    //MARK: - userdefined Functions
    
    // MARK: - setup ARView
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }

    func resetARSession(){
        isObjectVisible = false
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == nodeName{
                node.removeFromParentNode()
            }
        }
        addedNodes = []
        configuration.planeDetection = planeType
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        //sceneView.debugOptions = [.showFeaturePoints]
        session.run(configuration, options: [.resetTracking,.removeExistingAnchors])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
        })
    }
    
    func updateARSession(){
        configuration.planeDetection = planeType
        session.run(configuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.updateFocusSquare()
        })
    }
    
    //MARK: - FocusSquare
    func updateFocusSquare() {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
            return
        } else {
            focusSquare.unhide()
        }
        
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
           let query = sceneView.getRaycastQuery(),
           let result = sceneView.castRay(for: query).first {
            
            DispatchQueue.main.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera)
            }
            if !coachingOverlay.isActive {
               
            }
        } else {
            DispatchQueue.main.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
        }
    }
    
    // MARK: - Manage Models
    
    func addModel(x: Float = 0, y: Float = 0, z: Float = -0.2, fileName: String = "Dragon 2.5_dae.dae") {
        
        let fileNameComponents = fileName.split(separator: ".").map { String($0) }
        let fileExt = fileNameComponents.last
        self.nodeName = fileNameComponents.first ?? "theNameOfTheParentNodeOfTheObject"
        var scnFileName = fileName
        if fileName.count > 4 && fileName.contains(".scn"){
            scnFileName.removeLast(4)
        }
        
        if fileExt == "scn"{
            guard let scnScene = SCNScene(named: fileName), let scnSceneNode = scnScene.rootNode.childNode(withName: scnFileName, recursively: true) else { return }
            scnSceneNode.worldPosition = SCNVector3(x, y, z)
            addedNodes.append(scnSceneNode)
            sceneView.scene.rootNode.addChildNode(scnSceneNode)
        }else if fileExt == "dae"{
            guard let modelScene = SCNScene(named: fileName) else { return }
            let modelNode = SCNNode()
            let modelSceneChildNodes = modelScene.rootNode.childNodes
            for childNode in modelSceneChildNodes {
                modelNode.addChildNode(childNode)
            }
            modelNode.worldPosition = SCNVector3(x, y, z)
            let scale = 0.009
            modelNode.scale = SCNVector3(scale, scale, scale)
            addedNodes.append(modelNode)
            sceneView.scene.rootNode.addChildNode(modelNode)
        }else if fileExt == "usdz"{
            print("getting file path")
            guard let urlPath = Bundle.main.url(forResource: self.nodeName, withExtension: "usdz") else {
                print("getting file path failed",self.nodeName)
                return
            }
            let mdlAsset = MDLAsset(url: urlPath)
            mdlAsset.loadTextures()
            let asset = mdlAsset.object(at: 0) // extract first object
            let assetNode = SCNNode(mdlObject: asset)
            assetNode.worldPosition = SCNVector3(x, y, z)
            assetNode.name = self.nodeName
            assetNode.categoryBitMask = BodyType.ObjectModel.rawValue
            assetNode.enumerateChildNodes { (node, _) in
                node.categoryBitMask = BodyType.ObjectModel.rawValue
            }
            addedNodes.append(assetNode)
            sceneView.scene.rootNode.addChildNode(assetNode)
        }else{
            print("invalid format")
        }
    }
    
    // MARK: - Gestures
    func addGestureToSceneView() {
        // to add or remove object on touch
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARDesignViewer.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Change Size of Object
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ARDesignViewer.didPinch(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        // To move object around
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ARDesignViewer.didPan(withGestureRecognizer:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        // Tp rotate object
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action:#selector(ARDesignViewer.didRotate(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(rotationGestureRecognizer)
        
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        // to add object when tapped
        let (_, _, hitResults, _) = AppUtils.doHitTestWithARRaycast(tapLocation, in: self.sceneView, objectPos: nil)
        if let result = hitResults?.first{
            if addedNodes.isEmpty{
                addModel(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z,fileName: modelName)
                isObjectVisible = true
            }
            //            print("adding anchor")
            //            let anchor = ARAnchor(name: self.nodeName, transform: result.worldTransform)
            //            sceneView.session.add(anchor: anchor)
        }
    }
    
    
    @objc func didPinch(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began{
            guard let sceneView = recognizer.view as? ARSCNView else{
                return
            }
            
            let touch = recognizer.location(in: sceneView)
            let hitTestResults = self.sceneView.hitTest(touch, options: nil)
            
            if let hitTest = hitTestResults.first{
                guard let objectNode = AppUtils.getParentNodeOf(hitTest.node, self.nodeName) else { return }
                selectedNode = objectNode
            }
        }
        
        if recognizer.state == .changed{
            guard (recognizer.view as? ARSCNView) != nil else{
                return
            }
            if let selectedNode = selectedNode{
                let pinchScaleX = Float(recognizer.scale) * selectedNode.scale.x
                let pinchScaleY = Float(recognizer.scale) * selectedNode.scale.y
                let pinchScaleZ = Float(recognizer.scale) * selectedNode.scale.z
                
                selectedNode.scale = SCNVector3(pinchScaleX,pinchScaleY,pinchScaleZ)
                recognizer.scale = 1
            }
        }
        
        if recognizer.state == .ended{
            selectedNode = nil
        }
    }
    
    @objc func didPan(withGestureRecognizer recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began{
            guard let sceneView = recognizer.view as? ARSCNView else{
                return
            }
            let touch = recognizer.location(in: sceneView)
            let hitTestResults = self.sceneView.hitTest(touch, options: nil)
            if let hitTest = hitTestResults.first{
                guard let objectNode = AppUtils.getParentNodeOf(hitTest.node, self.nodeName) else { return }
                selectedNode = objectNode
            }
        }
        
        if recognizer.state == .changed{
            guard let sceneView = recognizer.view as? ARSCNView else{
                return
            }
            if let selectedNode = selectedNode{
                let touch = recognizer.location(in: sceneView)
                let (_, _, hitResults, _) = AppUtils.doHitTestWithARRaycast(touch, in: sceneView, objectPos: nil)
                
                if let result = hitResults?.first{
                    selectedNode.worldPosition = SCNVector3(result.worldTransform.translation)
                }
            }
        }
        
        if recognizer.state == .ended{
            selectedNode = nil
        }
        
    }
    
    @objc func didRotate(withGestureRecognizer recognizer: UIRotationGestureRecognizer) {
        /*
         - Note:
         For looking down on the object (99% of all use cases), we need to subtract the angle.
         To make rotation also work correctly when looking from below the object one would have to
         flip the sign of the angle depending on whether the object is above or below the camera...
         */
        if recognizer.state == .began{
            guard let sceneView = recognizer.view as? ARSCNView else{
                return
            }
            let touch = recognizer.location(in: sceneView)
            let hitTestResults = self.sceneView.hitTest(touch, options: nil)
            if let hitTest = hitTestResults.first{
                guard let objectNode = AppUtils.getParentNodeOf(hitTest.node, self.nodeName) else { return }
                selectedNode = objectNode
            }
        }
        
        if recognizer.state == .changed{
            if let selectedNode = selectedNode {
                selectedNode.eulerAngles.y -= Float(recognizer.rotation)
            }
            recognizer.rotation = 0
        }
        
        if recognizer.state == .ended{
            selectedNode = nil
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ARDesignViewer: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
