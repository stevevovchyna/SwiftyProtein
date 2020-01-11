//
//  ARViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 06.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
        
    var ligandToDisplay: Ligand?
    var geometryNode: SCNNode = SCNNode()
    var ligandNode: SCNNode = SCNNode()
    var planes = [ARPlaneAnchor: Plane]()
    var ligandAddedToScene: Bool = false
    
    var currentAngleY: Float = 0.0
    var isRotating = false
    var isScaling = false
    var currentNode: SCNNode? = nil
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        gestureSetup()
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - touch observers
    
    @IBAction func refreshScene(_ sender: UIBarButtonItem) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        self.sceneView.session.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
        ligandAddedToScene = false
    }
    
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        if let node = hitTestResults.first?.node {
            if let plane = node.parent as? Plane,
                let planeParent = plane.parent,
                let liganda = ligandToDisplay,
                ligandAddedToScene == false {
                let ligand = liganda.createARLigandNode()
                planeParent.addChildNode(ligand)
                sessionInfoLabel.text = "Here's your \(liganda.name)"
                sessionInfoView.isHidden = false
                ligandAddedToScene = true
                currentNode = ligand
            } else if !ligandAddedToScene {
                sessionInfoLabel.text = "Seems like this plane is not accessible yet - move your device around or find another surface to be able to add ligand"
                sessionInfoView.isHidden = false
            }
            if node.name != nil, let parent = currentNode {
                let newNode = atomNameNode(for: node)
                parent.addChildNode(newNode)
            }
        }
    }
    
    @objc func moveNode(_ gesture: UIPanGestureRecognizer) {
        guard let currentNode = currentNode, isRotating == false else { return }
        let currentTouchPoint = gesture.location(in: sceneView)
        guard let hitTest = sceneView.hitTest(currentTouchPoint, types: .existingPlane).first else { return }
        let worldTransform = hitTest.localTransform
        let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
        currentNode.simdPosition = SIMD3<Float>(newPosition.x, newPosition.y, newPosition.z)
    }
    
    @objc func rotateNode(_ gesture: UIRotationGestureRecognizer){
        guard let currentNode = currentNode else { return }
        let rotation = Float(gesture.rotation)
        switch gesture.state {
        case .changed:
            isRotating = true
            currentNode.eulerAngles.y = currentAngleY - rotation
        case .ended:
            currentAngleY = currentNode.eulerAngles.y
            isRotating = false
        default:
            break
        }
    }
    
    @objc func scaleNode(_ gesture: UIPinchGestureRecognizer) {
        guard let nodeToScale = currentNode else { return }
        switch gesture.state {
        case .changed:
            isScaling = true
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.z))
            nodeToScale.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
        case .ended:
            isScaling = false
        default:
            break
        }
    }
    
    // MARK: - Tag: render methods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, self.ligandAddedToScene == false {
                let plane = Plane(planeAnchor)
                self.planes[planeAnchor] = plane
                node.addChildNode(plane)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor,
                self.ligandAddedToScene == false,
                let plane = self.planes[planeAnchor] {
                    plane.update(planeAnchor)
            }
        }
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver

    func sessionWasInterrupted(_ session: ARSession) {
        sessionInfoLabel.text = "Session was interrupted"
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Back", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private methods

    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        let message: String

        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            message = "Move the device around to detect horizontal and vertical surfaces."
        case .notAvailable:
            message = "Tracking unavailable."
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limited(.initializing):
            message = "Initializing AR session."
        default:
            message = ""
        }
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }

    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func gestureSetup() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapScreen))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveNode(_:)))
        self.view.addGestureRecognizer(panGesture)

        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode(_:)))
        self.view.addGestureRecognizer(rotateGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleNode(_:)))
        self.view.addGestureRecognizer(pinchGesture)
    }
    
    private func setupNavBar() {
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
}
