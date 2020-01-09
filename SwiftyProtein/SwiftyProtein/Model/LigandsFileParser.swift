//
//  LigandsFileParser.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 09.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation

func parseLigandFile() -> Result<[String]> {
    let fileName = "ligands"
    let fileExtension = "txt"
    guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) else { return .error("Error locating file") }
    do {
        let string = try String(contentsOfFile: path)
        var result = string.components(separatedBy: "\n")
        result.removeLast()
        return .success(result)
    } catch {
        return .error(error.localizedDescription)
    }
}
