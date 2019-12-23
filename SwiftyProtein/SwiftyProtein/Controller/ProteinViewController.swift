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
            sphereNode.position = SCNVector3(x: atom.xPos, y: atom.yPos, z: atom.zPoz)
            liganeMolecule.addChildNode(sphereNode)
        }
        for bonds in ligand.allConects {
            for bond in bonds.bondAtoms {
                let newBond = SCNNode()
                let startAtom = ligand.allAtoms[bonds.id - 1]
                let endAtom = ligand.allAtoms[bond - 1]
                let startVector = SCNVector3(x: startAtom.xPos, y: startAtom.yPos, z: startAtom.zPoz)
                let endVector = SCNVector3(x: endAtom.xPos, y: endAtom.yPos, z: endAtom.zPoz)
                liganeMolecule.addChildNode(newBond.buildConect(from: startVector, to: endVector, radius: 0.05, color: .black))
            }
        }
        return liganeMolecule
    }
}

extension SCNNode {

        func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
            let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
            if length == 0 {
                return SCNVector3(0.0, 0.0, 0.0)
            }

            return SCNVector3( iv.x / length, iv.y / length, iv.z / length)

        }
        
        func buildConect(from startPoint: SCNVector3,
                                  to endPoint: SCNVector3,
                                  radius: CGFloat,
                                  color: UIColor) -> SCNNode {
            let w = SCNVector3(x: endPoint.x-startPoint.x,
                               y: endPoint.y-startPoint.y,
                               z: endPoint.z-startPoint.z)
            let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))

            if l == 0.0 {
                // two points together.
                let sphere = SCNSphere(radius: radius)
                sphere.firstMaterial?.diffuse.contents = color
                self.geometry = sphere
                self.position = startPoint
                return self

            }

            let cyl = SCNCylinder(radius: radius, height: l)
            cyl.firstMaterial?.diffuse.contents = color

            self.geometry = cyl

            //original vector of cylinder above 0,0,0
            let ov = SCNVector3(0, l/2.0,0)
            //target vector, in new coordination
            let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                                (endPoint.z-startPoint.z)/2.0)

            // axis between two vector
            let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)

            //normalized axis vector
            let av_normalized = normalizeVector(av)
            let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
            let q1 = Float(av_normalized.x) // x' * sin(angle/2)
            let q2 = Float(av_normalized.y) // y' * sin(angle/2)
            let q3 = Float(av_normalized.z) // z' * sin(angle/2)

            let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
            let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
            let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
            let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
            let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
            let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
            let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
            let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
            let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3

            self.transform.m11 = r_m11
            self.transform.m12 = r_m12
            self.transform.m13 = r_m13
            self.transform.m14 = 0.0

            self.transform.m21 = r_m21
            self.transform.m22 = r_m22
            self.transform.m23 = r_m23
            self.transform.m24 = 0.0

            self.transform.m31 = r_m31
            self.transform.m32 = r_m32
            self.transform.m33 = r_m33
            self.transform.m34 = 0.0

            self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
            self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
            self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
            self.transform.m44 = 1.0
            return self
        }
}

class ProteinViewController: UIViewController {
    
    var ligandToDisplay: Ligand?
    @IBOutlet weak var sceneView: SCNView!
    
    var geometryNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

