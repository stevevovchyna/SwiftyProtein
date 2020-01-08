//
//  Ligand.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

struct Atom {
    let id: Int
    let atom_name: String
    var xPos: Float
    var yPos: Float
    var zPos: Float

    init(atomData: String) {
        id = (atomData[atomData.index(atomData.startIndex, offsetBy: 6)...atomData.index(atomData.startIndex, offsetBy: 10)] as NSString).integerValue
        atom_name = String(atomData[atomData.index(atomData.startIndex, offsetBy: 76)...atomData.index(atomData.startIndex, offsetBy: 77)]).trimmingCharacters(in: .whitespacesAndNewlines)
        xPos = (atomData[atomData.index(atomData.startIndex, offsetBy: 30)...atomData.index(atomData.startIndex, offsetBy: 37)] as NSString).floatValue
        yPos = (atomData[atomData.index(atomData.startIndex, offsetBy: 38)...atomData.index(atomData.startIndex, offsetBy: 45)] as NSString).floatValue
        zPos = (atomData[atomData.index(atomData.startIndex, offsetBy: 47)...atomData.index(atomData.startIndex, offsetBy: 54)] as NSString).floatValue
    }
}

struct Conect {
    let id: Int
    var bondAtoms: [Int]
    
    init(conectData data: String) {
        id = (data[data.index(data.startIndex, offsetBy: 6)...data.index(data.startIndex, offsetBy: 10)] as NSString).integerValue
        let bondsString = String(data[data.index(data.startIndex, offsetBy: 11)...data.index(before: data.endIndex)])
        var bondsArray = bondsString.components(separatedBy: " ")
        bondsArray = bondsArray.filter{ $0 != "" }
        bondAtoms = []
        for bond in bondsArray {
            self.bondAtoms.append((bond as NSString).integerValue)
        }
    }
}

struct LigandInfo {
    let name : String
    let identifiers : String
    let formula : String
    let formulaWeight : String
    let type : String
    let smiles : String
    let inchi : String
    let inchiKey : String
    
    let formalCharge : String
    let atomCount : String
    let chiralAtomCount : String
    let chiralAtomsStr : String
    let bondCount : String
    let aromaticBondCount : String
}

extension LigandInfo {
    init(json: [[String: Any]]) {
        self.aromaticBondCount = String(json[0]["aromaticBondCount"] as? Double ?? 0)
        self.atomCount = String(json[0]["atomCount"] as? Double ?? 0)
        self.bondCount = String(json[0]["bondCount"] as? Double ?? 0)
        self.chiralAtomCount = String(json[0]["chiralAtomCount"] as? Double ?? 0)
        self.chiralAtomsStr = json[0]["chiralAtomsStr"] as? String ?? "No data"
        self.formalCharge = String(json[0]["formalCharge"] as? Double ?? 0)
        self.formula = json[0]["formula"] as? String ?? "No data"
        self.formulaWeight = json[0]["formulaWeight"] as? String ?? "No data"
        self.identifiers = json[0]["identifiers"] as? String ?? "No data"
        self.inchi = json[0]["inchi"] as? String ?? "No data"
        self.inchiKey = json[0]["inchiKey"] as? String ?? "No data"
        self.smiles = json[0]["smiles"] as? String ?? "No data"
        self.type = json[0]["type"] as? String ?? "No data"
        self.name = json[0]["name"] as? String ?? "No data"
    }
}

struct Ligand {
    let name: String
    var allAtoms: [Atom] = []
    var allConects: [Conect] = []
    var info: LigandInfo? = nil
    
    init(forLigand ligand: String, withDataSet data: String) {

        let stringsArray = data.components(separatedBy: "\n")
        var atomStrings: [String] = []
        var conectStrings: [String] = []
        for entry in stringsArray {
            if entry.starts(with: "ATOM") {
                atomStrings.append(entry)
            } else if entry.starts(with: "CONECT") {
                conectStrings.append(entry)
            }
        }
        for atom in atomStrings {
            allAtoms.append(Atom(atomData: atom))
        }
        for conect in conectStrings {
            allConects.append(Conect(conectData: conect))
        }
        name = ligand
    }
    
    mutating func addInfo(with info: LigandInfo) {
        self.info = info
    }
}

extension Ligand {
    func createLigandNode() -> SCNNode {
        let liganeMolecule = SCNNode()
        liganeMolecule.physicsBody?.type = .static
        liganeMolecule.name = "ligand"
        for atom in allAtoms {
            let sphere = SCNSphere(radius: 0.2)
            sphere.firstMaterial?.diffuse.contents = getAtomColor(name: atom.atom_name)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(x: atom.xPos, y: atom.yPos, z: atom.zPos)
            sphereNode.name = atom.atom_name
            liganeMolecule.addChildNode(sphereNode)
        }
        for bonds in allConects {
            for bond in bonds.bondAtoms {
                let newBond = SCNNode()
                let startAtom = allAtoms[bonds.id - 1]
                let endAtom = allAtoms[bond - 1]
                let startVector = SCNVector3(x: startAtom.xPos, y: startAtom.yPos, z: startAtom.zPos)
                let endVector = SCNVector3(x: endAtom.xPos, y: endAtom.yPos, z: endAtom.zPos)
                liganeMolecule.addChildNode(newBond.buildConect(from: startVector, to: endVector, radius: 0.05, color: .black))
            }
        }
        return liganeMolecule
    }
    
    private func getAtomColor(name: String) -> UIColor {
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

extension Ligand {
    func createARLigandNode() -> SCNNode {
        var minVec = SCNVector3Zero
        var maxVec = SCNVector3Zero
        let ligand = self.createLigandNode()
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
}

