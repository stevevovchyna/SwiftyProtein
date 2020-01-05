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
    let authString = "https://files.rcsb.org/ligands/view/\(ligand.lowercased())_ideal.pdb"
    let url = URL(string: authString)
    var request = URLRequest(url: url!)
    request.httpMethod = "get"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        DispatchQueue.main.async {
            guard error == nil else { return completion(.error(error!.localizedDescription)) }
            guard let data = data, let res = response as? HTTPURLResponse, res.statusCode == 200 else { return completion(.error("No data returned")) }
            guard let resultString = String(data: data, encoding: .utf8) else { return completion(.error("Invalid data obtained"))}
            let ligandOut = Ligand(forLigand: ligand, withDataSet: resultString)
            completion(.success(ligandOut))
        }
    }.resume()
}

func requestLigandInfo(forLigand ligand: String, completion: @escaping (Result<[LigandInfo]>) -> Void) {
    let authString = "https://rest.rcsb.org/rest/ligands/\(ligand.lowercased())"
    let url = URL(string: authString)
    var request = URLRequest(url: url!)
    request.httpMethod = "get"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else { return completion(.error(error!.localizedDescription)) }
        guard let data = data, let res = response as? HTTPURLResponse, res.statusCode == 200 else { return completion(.error("No data returned")) }
        var ligandInfo : [LigandInfo] = []
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let result = json["results"] else { return completion(.error("There was an issue with the returned data")) }
        let info = LigandInfo(json: result as! [[String : Any]])
        ligandInfo.append(info)
        completion(.success(ligandInfo))
    }.resume()
}
