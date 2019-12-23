//
//  ListViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var ligands : [String] = ligandsArray
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ligands.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandeCell", for: indexPath)
        cell.textLabel?.text = ligands[indexPath.row]
        return cell
    }

    // MARK: - SearchBar methods

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            ligands = ligandsArray
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            ligands = ligandsArray.filter { $0.lowercased().contains(searchText.lowercased()) }
            tableView.reloadData()
        }
    }
    
}
