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
    let id: String
    let atom_name: String
//    let label_atom_id: String
//    let charge: Double
//    let pdbx_align: Double
//    let pdbx_aromatic_flag: String
//    let pdbx_leaving_atom_flag: String
//    let pdbx_stereo_config: String
    let model_Cartn_x: Float
    let model_Cartn_y: Float
    let model_Cartn_z: Float
//    let pdbx_model_Cartn_x_ideal: Double
//    let pdbx_model_Cartn_y_ideal: Double
//    let pdbx_model_Cartn_z_ideal: Double
//    let pdbx_component_atom_id: String
//    let pdbx_component_comp_id: String
//    let pdbx_ordinal: String

    init(atomData: [String]) {
        id = atomData[1] == "" ? "N" : atomData[1]
        
        
//        charge = atomData[2] == "" ? 0 : (atomData[2] as NSString).doubleValue
//        pdbx_align = atomData[3] == "" ? 0 : (atomData[3] as NSString).doubleValue
//        pdbx_aromatic_flag = atomData[4] == "" ? "N" : atomData[4]
//        pdbx_leaving_atom_flag = atomData[5] == "" ? "N" : atomData[5]
//        pdbx_stereo_config = atomData[6] == "" ? "N" : atomData[6]
        
        model_Cartn_x = atomData[6] == "" ? 0 : (atomData[6] as NSString).floatValue
        model_Cartn_y = atomData[7] == "" ? 0 : (atomData[7] as NSString).floatValue
        model_Cartn_z = atomData[8] == "" ? 0 : (atomData[8] as NSString).floatValue
        
        atom_name = atomData[11] == "" ? "N" : atomData[11]
//        pdbx_model_Cartn_x_ideal = atomData[10] == "" ? 0 : (atomData[10] as NSString).doubleValue
//        pdbx_model_Cartn_y_ideal = atomData[11] == "" ? 0 : (atomData[11] as NSString).doubleValue
//        pdbx_model_Cartn_z_ideal = atomData[12] == "" ? 0 : (atomData[12] as NSString).doubleValue
//        pdbx_component_atom_id = atomData[13] == "" ? "N" : atomData[13]
//        pdbx_component_comp_id = atomData[14] == "" ? "N" : atomData[14]
//        pdbx_ordinal = atomData[15] == "" ? "N" : atomData[15]
    }
}

//struct Conect {
//    let alt_atom_id: String
//    let type_symbol: String
//    let pdbx_aromatic_flag: String
//    let pdbx_leaving_atom_flag: String
//    let pdbx_stereo_config: String
//    let model_Cartn_x: Double
//    let model_Cartn_y: Double
//    let model_Cartn_z: Double
//    let pdbx_model_Cartn_x_ideal: Double
//    let pdbx_model_Cartn_y_ideal: Double
//    let pdbx_model_Cartn_z_ideal: Double
//    let pdbx_component_atom_id: String
//    let pdbx_component_comp_id: String
//    let pdbx_ordinal: String
//
//    init(atomData: [String]) {
//        alt_atom_id = atomData[0] == "" ? "N" : atomData[0]
//        type_symbol = atomData[1] == "" ? "N" : atomData[2]
//        pdbx_aromatic_flag = atomData[4] == "" ? "N" : atomData[4]
//        pdbx_leaving_atom_flag = atomData[5] == "" ? "N" : atomData[5]
//        pdbx_stereo_config = atomData[6] == "" ? "N" : atomData[6]
//        model_Cartn_x = atomData[7] == "" ? 0 : (atomData[7] as NSString).doubleValue
//        model_Cartn_y = atomData[8] == "" ? 0 : (atomData[8] as NSString).doubleValue
//        model_Cartn_z = atomData[9] == "" ? 0 : (atomData[9] as NSString).doubleValue
//        pdbx_model_Cartn_x_ideal = atomData[10] == "" ? 0 : (atomData[10] as NSString).doubleValue
//        pdbx_model_Cartn_y_ideal = atomData[11] == "" ? 0 : (atomData[11] as NSString).doubleValue
//        pdbx_model_Cartn_z_ideal = atomData[12] == "" ? 0 : (atomData[12] as NSString).doubleValue
//        pdbx_component_atom_id = atomData[13] == "" ? "N" : atomData[13]
//        pdbx_component_comp_id = atomData[14] == "" ? "N" : atomData[14]
//        pdbx_ordinal = atomData[15] == "" ? "N" : atomData[15]
//    }
//}

class Ligand {
    let name: String
    var allAtoms: [Atom] = []
//    let allConects: [Conect]
    
    init(forLigand ligand: String, withDataSet data: String) {
        let stringsArray = data.components(separatedBy: "\n")
        var atoms : [[String]] = []
        for line in stringsArray {
            var atom = line.components(separatedBy: " ")
            atom = atom.filter{ $0 != "" }
            atoms.append(atom)
        }
        for atom in atoms {
            if atom.contains("ATOM") {
                allAtoms.append(Atom(atomData: atom))
            }
        }
        name = ligand
    }
}
