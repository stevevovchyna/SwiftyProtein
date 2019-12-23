//
//  ProteinViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import SceneKit

class Atoms {
    class func addLigandAtoms(ligand: Ligand) -> SCNNode {
        let liganeMolecule = SCNNode()
        for atom in ligand.allAtoms {
            let sphere = SCNSphere(radius: 0.2)
            switch atom.atom_name {
            case "C":
                sphere.firstMaterial?.diffuse.contents = UIColor.black
            case "H":
                sphere.firstMaterial?.diffuse.contents = UIColor.white
            case "N":
                sphere.firstMaterial?.diffuse.contents = UIColor.blue
            case "O":
                sphere.firstMaterial?.diffuse.contents = UIColor.red
            case "F", "Cl":
                sphere.firstMaterial?.diffuse.contents = UIColor.green
            case "Br":
                sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
            case "I":
                sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            case "He", "Ne", "Ar", "Xe", "Kr":
                sphere.firstMaterial?.diffuse.contents = UIColor.cyan
            case "P":
                sphere.firstMaterial?.diffuse.contents = UIColor.orange
            case "S":
                sphere.firstMaterial?.diffuse.contents = UIColor.yellow
            case "B":
                sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            case "Li", "Na", "K", "Rb", "Cs", "Fr":
                sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            case "Be", "Mg", "Ca", "Sr", "Ba", "Ra":
                sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
            case "Fe":
                sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            case "Ti":
                sphere.firstMaterial?.diffuse.contents = UIColor.gray
            default:
                sphere.firstMaterial?.diffuse.contents = UIColor.systemPink
            }
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(x: atom.model_Cartn_x, y: atom.model_Cartn_y, z: atom.model_Cartn_z)
            liganeMolecule.addChildNode(sphereNode)
        }
        return liganeMolecule
    }
}

class ProteinViewController: UIViewController {
    
    var ligandToDisplay: Ligand?
    @IBOutlet weak var sceneView: SCNView!
    
    var geometryNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let lig = ligandToDisplay else { return }
        
        sceneSetup()
        geometryNode = Atoms.addLigandAtoms(ligand: ligandToDisplay!)
        sceneView.scene!.rootNode.addChildNode(geometryNode)
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
      cameraNode.position = SCNVector3Make(0, 0, 25)
      scene.rootNode.addChildNode(cameraNode)
            
      sceneView.scene = scene
    }
    

}

