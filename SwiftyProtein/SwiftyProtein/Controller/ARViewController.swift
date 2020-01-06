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

class ARViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    var ligandScene : SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let ligand = ligandScene else { return }
        sceneView.scene.rootNode.addChildNode(ligand)

        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func addBox() {
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else { return }
        node.removeFromParentNode()
    }

}

extension ARViewController: ARSKViewDelegate {
    func session(_ session: ARSession,
               didFailWithError error: Error) {
        print("Session Failed - probably due to lack of camera access")
    }
  
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
    }
  
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session resumed")
        sceneView.session.run(session.configuration!,
                        options: [.resetTracking,
                                  .removeExistingAnchors])
    }
}
