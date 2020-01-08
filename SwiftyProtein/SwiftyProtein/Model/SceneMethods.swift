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
import ARKit

func addLigandAtoms(ligand: Ligand) -> SCNNode {
    let liganeMolecule = SCNNode()
    liganeMolecule.physicsBody?.type = .static
    liganeMolecule.name = "ligand"
    for atom in ligand.allAtoms {
        let sphere = SCNSphere(radius: 0.2)
        sphere.firstMaterial?.diffuse.contents = getAtomColor(name: atom.atom_name)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x: atom.xPos, y: atom.yPos, z: atom.zPos)
        sphereNode.name = atom.atom_name
        liganeMolecule.addChildNode(sphereNode)
    }
    for bonds in ligand.allConects {
        for bond in bonds.bondAtoms {
            let newBond = SCNNode()
            let startAtom = ligand.allAtoms[bonds.id - 1]
            let endAtom = ligand.allAtoms[bond - 1]
            let startVector = SCNVector3(x: startAtom.xPos, y: startAtom.yPos, z: startAtom.zPos)
            let endVector = SCNVector3(x: endAtom.xPos, y: endAtom.yPos, z: endAtom.zPos)
            liganeMolecule.addChildNode(newBond.buildConect(from: startVector, to: endVector, radius: 0.05, color: .black))
        }
    }
    return liganeMolecule
}
    
func getAtomColor(name: String) -> UIColor {
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

func createARLigand(with ligandData: Ligand) -> SCNNode {
    var minVec = SCNVector3Zero
    var maxVec = SCNVector3Zero
    let ligand = addLigandAtoms(ligand: ligandData)
    (minVec, maxVec) =  ligand.boundingBox
    ligand.pivot = SCNMatrix4MakeTranslation(
        minVec.x + (maxVec.x - minVec.x)/2,
        minVec.y,
        minVec.z + (maxVec.z - minVec.z)/2
    )
    ligand.scale = SCNVector3(0.05, 0.05, 0.05)
    ligand.position = SCNVector3Zero
    return ligand
}
