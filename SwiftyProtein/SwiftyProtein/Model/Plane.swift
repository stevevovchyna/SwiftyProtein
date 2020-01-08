//
//  Plane.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 07.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import ARKit

extension UIColor {
    static let planeColor = UIColor.systemYellow
}

//class Plane: SCNNode {
//
//    let meshNode: SCNNode
//    let extentNode: SCNNode
//    var classificationNode: SCNNode?
//
//    /// - Tag: VisualizePlane
//    init(anchor: ARPlaneAnchor, in sceneView: ARSCNView) {
//
//        #if targetEnvironment(simulator)
//        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
//        #else
//
//        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
//            else { fatalError("Can't create plane geometry") }
//        meshGeometry.update(from: anchor.geometry)
//        meshNode = SCNNode(geometry: meshGeometry)
//
//        let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//        extentNode = SCNNode(geometry: extentPlane)
//        extentNode.simdPosition = anchor.center
//
//        extentNode.eulerAngles.x = -.pi / 2
//
//        super.init()
//
//        self.setupMeshVisualStyle()
//        self.setupExtentVisualStyle()
//
//        addChildNode(meshNode)
//        addChildNode(extentNode)
//
//        if #available(iOS 12.0, *), ARPlaneAnchor.isClassificationSupported {
//            let classification = anchor.classification.description
//            let textNode = self.makeTextNode(classification)
//            classificationNode = textNode
//            textNode.centerAlign()
//            extentNode.addChildNode(textNode)
//        }
//        #endif
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//    private func setupMeshVisualStyle() {
//        meshNode.opacity = 0.25
//        guard let material = meshNode.geometry?.firstMaterial
//            else { fatalError("ARSCNPlaneGeometry always has one material") }
//        material.diffuse.contents = UIColor.planeColor
//    }
//
//    private func setupExtentVisualStyle() {
//        extentNode.opacity = 0.6
//
//        guard let material = extentNode.geometry?.firstMaterial
//            else { fatalError("SCNPlane always has one material") }
//
//        material.diffuse.contents = UIColor.planeColor
//
//        guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "Assets.scnassets")
//            else { fatalError("Can't find wireframe shader") }
//        do {
//            let shader = try String(contentsOfFile: path, encoding: .utf8)
//            material.shaderModifiers = [.surface: shader]
//        } catch {
//            fatalError("Can't load wireframe shader: \(error)")
//        }
//    }
//
//    private func makeTextNode(_ text: String) -> SCNNode {
//        let textGeometry = SCNText(string: text, extrusionDepth: 1)
//        textGeometry.font = UIFont(name: "Futura", size: 75)
//
//        let textNode = SCNNode(geometry: textGeometry)
//
//        textNode.simdScale = SIMD3<Float>(repeating: 0.0005)
//
//        return textNode
//    }
//}

class Plane: SCNNode {
    var planeAnchor: ARPlaneAnchor
    
    var planeGeometry: SCNPlane
    var planeNode: SCNNode
    var shadowPlaneGeometry: SCNPlane
    var shadowNode: SCNNode
    
    init(_ anchor: ARPlaneAnchor) {
        
        self.planeAnchor = anchor
        
        let grid = UIImage(named: "plane_grid.png")
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = SCNMaterial()
        material.diffuse.contents = grid
        self.planeGeometry.materials = [material]
        
        self.planeGeometry.firstMaterial?.transparency = 0.5
        self.planeNode = SCNNode(geometry: planeGeometry)
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.planeNode.castsShadow = false
        
        self.shadowPlaneGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let shadowMaterial = SCNMaterial()
        shadowMaterial.diffuse.contents = UIColor.white
        shadowMaterial.lightingModel = .constant
        shadowMaterial.writesToDepthBuffer = true
        shadowMaterial.colorBufferWriteMask = []
        
        self.shadowPlaneGeometry.materials = [shadowMaterial]
        
        self.shadowNode = SCNNode(geometry: shadowPlaneGeometry)
        self.shadowNode.transform = planeNode.transform
        self.shadowNode.castsShadow = false
        
        super.init()
        
        self.addChildNode(planeNode)
        self.addChildNode(shadowNode)

        self.position = SCNVector3(anchor.center.x, -0.002, anchor.center.z) // 2 mm below the origin of plane.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        self.shadowPlaneGeometry.width = CGFloat(anchor.extent.x)
        self.shadowPlaneGeometry.height = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z)
    }
    
    func setPlaneVisibility(_ visible: Bool) {
        self.planeNode.isHidden = !visible
    }
}
