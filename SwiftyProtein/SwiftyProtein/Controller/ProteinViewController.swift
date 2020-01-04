//
//  ProteinViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import SceneKit

class ProteinViewController: UIViewController {
    
    var ligandToDisplay: Ligand?
    var ligandInfo : [LigandInfo] = []
    @IBOutlet weak var sceneView: SCNView!
    
    var geometryNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneSetup()
        geometryNode = Atoms.addLigandAtoms(ligand: ligandToDisplay!)
        sceneView.scene!.rootNode.addChildNode(geometryNode)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))

        sceneView.addGestureRecognizer(tap)

        print("In da hauz", ligandInfo[0].name)
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer){
           if rec.state == .ended {
                let location: CGPoint = rec.location(in: sceneView)
                let hits = self.sceneView.hitTest(location, options: nil)
                if !hits.isEmpty{
                    let tappedNode = hits.first?.node
                    print(tappedNode!.name!)
                }
           }
    }
    
    func sceneSetup() {
        let scene = SCNScene()
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
      
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLight.LightType.omni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
      
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 20)
        scene.rootNode.addChildNode(cameraNode)
            
        sceneView.scene = scene
    }
    
}

extension ProteinViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mirror = Mirror(reflecting: ligandInfo[0])
        return mirror.children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandInfo", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = ligandInfo[0].name
        case 1:
        cell.textLabel?.text = ligandInfo[0].name
        case 2:
        cell.textLabel?.text = ligandInfo[0].chiralAtomsStr
        case 3:
        cell.textLabel?.text = ligandInfo[0].bondCount
        case 4:
        cell.textLabel?.text = ligandInfo[0].formula
        case 5:
        cell.textLabel?.text = ligandInfo[0].name
        case 6:
        cell.textLabel?.text = ligandInfo[0].name
        case 7:
        cell.textLabel?.text = ligandInfo[0].name
        case 8:
        cell.textLabel?.text = ligandInfo[0].name
        case 9:
        cell.textLabel?.text = ligandInfo[0].name
        case 10:
        cell.textLabel?.text = ligandInfo[0].name
        default:
            cell.textLabel?.text = "No data"
        }
        return cell
    }
    
    
    
    
}

