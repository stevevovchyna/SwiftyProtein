//
//  SceneMethods.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 27.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Atoms {
    class func addLigandAtoms(ligand: Ligand) -> SCNNode {
        let liganeMolecule = SCNNode()
        liganeMolecule.physicsBody?.type = .static
        liganeMolecule.name = "ligand"
        for atom in ligand.allAtoms {
            let sphere = SCNSphere(radius: 0.2)
            sphere.firstMaterial?.diffuse.contents = getAtomColor(name: atom.atom_name)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(x: atom.xPos, y: atom.yPos, z: atom.zPos - 20)
            sphereNode.name = atom.atom_name
            liganeMolecule.addChildNode(sphereNode)
        }
        for bonds in ligand.allConects {
            for bond in bonds.bondAtoms {
                let newBond = SCNNode()
                let startAtom = ligand.allAtoms[bonds.id - 1]
                let endAtom = ligand.allAtoms[bond - 1]
                let startVector = SCNVector3(x: startAtom.xPos, y: startAtom.yPos, z: startAtom.zPos - 20)
                let endVector = SCNVector3(x: endAtom.xPos, y: endAtom.yPos, z: endAtom.zPos - 20)
                liganeMolecule.addChildNode(newBond.buildConect(from: startVector, to: endVector, radius: 0.05, color: .black))
            }
        }
        return liganeMolecule
    }
    
    static func getAtomColor(name: String) -> UIColor {
        switch name {
        case "C":
            return UIColor.black
        case "H":
            return UIColor.white
        case "N":
            return UIColor.blue
        case "O":
            return UIColor.red
        case "F", "Cl":
            return UIColor.green
        case "Br":
            return #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
        case "I":
            return #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        case "He", "Ne", "Ar", "Xe", "Kr":
            return UIColor.cyan
        case "P":
            return UIColor.orange
        case "S":
            return UIColor.yellow
        case "B":
            return #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        case "Li", "Na", "K", "Rb", "Cs", "Fr":
            return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        case "Be", "Mg", "Ca", "Sr", "Ba", "Ra":
            return #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        case "Fe":
            return #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        case "Ti":
            return UIColor.gray
        default:
            return UIColor.systemPink
        }
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
                let sphere = SCNSphere(radius: radius)
                sphere.firstMaterial?.diffuse.contents = color
                self.geometry = sphere
                self.position = startPoint
                return self
            }

            let cyl = SCNCylinder(radius: radius, height: l)
            cyl.firstMaterial?.diffuse.contents = color

            self.geometry = cyl
            let ov = SCNVector3(0, l/2.0,0)
            let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                                (endPoint.z-startPoint.z)/2.0)
            let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
            let av_normalized = normalizeVector(av)
            let q0 = Float(0.0)
            let q1 = Float(av_normalized.x)
            let q2 = Float(av_normalized.y)
            let q3 = Float(av_normalized.z)

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
