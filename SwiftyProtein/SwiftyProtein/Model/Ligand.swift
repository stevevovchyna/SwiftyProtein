//
//  Ligand.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

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

enum SerializationError: Error {
    case missing(String)
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
}
