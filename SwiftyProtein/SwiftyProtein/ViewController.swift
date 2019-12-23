//
//  ViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authString = "https://www.rcsb.org/pdb/rest/describeHet?chemicalID=001"
        let url = URL(string: authString)
        var request = URLRequest(url: url!)
        request.httpMethod = "get"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }.resume()

    }

}

