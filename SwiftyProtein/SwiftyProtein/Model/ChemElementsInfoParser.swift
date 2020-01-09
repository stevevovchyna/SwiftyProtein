//
//  ChemElementsInfoParser.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 09.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation

struct Element {
    var name: String = "No data"
    var atomicMass : Double = -1
    var number: Int = -1
    var phase: String = "No data"
    var summary: String = "No data"
    var symbol: String = "No data"
    
    init(from json: [[String: Any]], with element: String) {
        for el in json {
            if (el["symbol"] as! String).lowercased() == element.lowercased() {
                name = el["name"] as? String ?? "No data"
                atomicMass = el["atomic_mass"] as? Double ?? -1
                number = el["number"] as? Int ?? -1
                phase = el["phase"] as? String ?? "No data"
                summary = el["summary"] as? String ?? "No data"
                symbol = el["symbol"] as? String ?? "No data"
            }
        }
    }
}

func getElementInfo(for element: String) -> Result<Element> {
    let fileName = "elements"
    let fileExtension = "json"
    guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) else { return .error("Error locating file") }
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonRes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let jsonResult = jsonRes, let result = jsonResult["elements"] else { return .error("Error locating file") }
        let element = Element(from: result as! [[String : Any]], with: element)
        return .success(element)
    } catch {
        return .error(error.localizedDescription)
    }
}
