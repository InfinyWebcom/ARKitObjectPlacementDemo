//
//  ExtensionsGlobalFunctions.swift
//  ArkitDemo
//
//  Created by Ajinkya on 15/11/21.
//

import Foundation
import ARKit

// MARK: enums
enum BodyType : Int {
    case ObjectModel = 2;
}

enum Settings: String {
    case verticalPlane
    case horizontalAndVerticalPlane
    case lockObject
}

// MARK: extensions
extension SCNNode {
    
    func setUniformScale(_ scale: Float) {
        self.simdScale = SIMD3<Float>(scale, scale, scale)
    }
    
    func renderOnTop(_ enable: Bool) {
        self.renderingOrder = enable ? 2 : 0
        if let geom = self.geometry {
            for material in geom.materials {
                material.readsFromDepthBuffer = enable ? false : true
            }
        }
        for child in self.childNodes {
            child.renderOnTop(enable)
        }
    }
}



extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
    */
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
    /**
     Factors out the orientation component of the transform.
    */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

extension RangeReplaceableCollection{
    mutating func keepLast(_ elementsToKeep: Int) {
        if count > elementsToKeep {
            self.removeFirst(count - elementsToKeep)
        }
    }
}

extension Array where Iterator.Element == Float {
    var average: Float? {
        guard !self.isEmpty else {
            return nil
        }
        
        let sum = self.reduce(Float(0)) { current, next in
            return current + next
        }
        return sum / Float(self.count)
    }
}

extension Array where Iterator.Element == SIMD3<Float> {
    var average: SIMD3<Float>? {
        guard !self.isEmpty else {
            return nil
        }
        
        let sum = self.reduce(SIMD3<Float>(repeating: 0)) { current, next in
            return current + next
        }
        return sum / Float(self.count)
    }
}

extension UserDefaults {
    func bool(for setting: Settings) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Settings) {
        set(bool, forKey: setting.rawValue)
    }
}


extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}


extension ARSCNView {
    /**
     Type conversion wrapper for original `unprojectPoint(_:)` method.
     Used in contexts where sticking to SIMD3<Float> type is helpful.
     */
    func unprojectPoint(_ point: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3<Float>(unprojectPoint(SCNVector3(point)))
    }
    
    // - Tag: CastRayForFocusSquarePosition
    func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
        return session.raycast(query)
    }

    // - Tag: GetRaycastQuery
    func getRaycastQuery(for alignment: ARRaycastQuery.TargetAlignment = .any) -> ARRaycastQuery? {
        return raycastQuery(from: screenCenter, allowing: .existingPlaneGeometry, alignment: alignment)
    }
    
//    func getRaycastQuery(for plane: ARWorldTrackingConfiguration.PlaneDetection = [.horizontal]) -> ARRaycastQuery? {
//        if plane == [.horizontal]{
//            return raycastQuery(from: screenCenter, allowing: .existingPlaneGeometry, alignment: .horizontal)
//        }else if plane == [.horizontal]{
//            return raycastQuery(from: screenCenter, allowing: .existingPlaneGeometry, alignment: .vertical)
//        }else{
//            return raycastQuery(from: screenCenter, allowing: .existingPlaneGeometry, alignment: .any)
//        }
//    }
    
    var screenCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
