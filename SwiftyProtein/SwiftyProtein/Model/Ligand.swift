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
    let xPos: Float
    let yPos: Float
    let zPoz: Float

    init(atomData: String) {
        id = (atomData[atomData.index(atomData.startIndex, offsetBy: 6)...atomData.index(atomData.startIndex, offsetBy: 10)] as NSString).integerValue
        atom_name = String(atomData[atomData.index(atomData.startIndex, offsetBy: 76)...atomData.index(atomData.startIndex, offsetBy: 77)]).trimmingCharacters(in: .whitespacesAndNewlines)
        xPos = (atomData[atomData.index(atomData.startIndex, offsetBy: 30)...atomData.index(atomData.startIndex, offsetBy: 37)] as NSString).floatValue
        yPos = (atomData[atomData.index(atomData.startIndex, offsetBy: 38)...atomData.index(atomData.startIndex, offsetBy: 45)] as NSString).floatValue
        zPoz = (atomData[atomData.index(atomData.startIndex, offsetBy: 47)...atomData.index(atomData.startIndex, offsetBy: 54)] as NSString).floatValue
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

class Ligand {
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
