//
//  Networking.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 04.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

enum Result<T> {
    case success(T)
    case error(String)
}

func requestLigand(forLigand ligand: String, atIndex index: Int, completion: @escaping (Result<Ligand>) -> Void) {
    let authString = "https://files.rcsb.org/lig/view/\(ligand.lowercased())_ideal.pdb"
    let url = URL(string: authString)
    var request = URLRequest(url: url!)
    request.httpMethod = "get"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data else { return }
        let resultString = String(data: data, encoding: .utf8)!
        let ligandOut = Ligand(forLigand: ligand, withDataSet: resultString)
        completion(.success(ligandOut))
    }.resume()
}

func requestLigandInfo(forLigand ligand: String, completion: @escaping ([LigandInfo]) -> Void) {
    let authString = "https://rest.rcsb.org/rest/ligands/\(ligand.lowercased())"
    let url = URL(string: authString)
    var request = URLRequest(url: url!)
    request.httpMethod = "get"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        var ligandInfo : [LigandInfo] = []
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            if let result = json["results"] {
                let info = LigandInfo(json: result as! [[String : Any]])
                    ligandInfo.append(info)
            }
        }
        completion(ligandInfo)
    }.resume()
}
