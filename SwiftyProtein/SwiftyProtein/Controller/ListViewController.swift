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
    var ligandToPass : Ligand?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        requestLigand(forLigand: ligands[indexPath.row]){ result in
            DispatchQueue.main.async {
                if result != "" {
                    self.ligandToPass = Ligand(forLigand: self.ligands[indexPath.row], withDataSet: result)
                    self.performSegue(withIdentifier: "showLigand", sender: self)
                } else {
                    self.presentAlert(text: "Oops! This ligand is not available at the moment")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLigand" {
            let vc = segue.destination as! ProteinViewController
            vc.ligandToDisplay = ligandToPass
        }
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
    
    func requestLigand(forLigand ligand: String, completion: @escaping (String) -> Void) {
        let authString = "https://files.rcsb.org/ligands/view/\(ligand.lowercased())_ideal.pdb"
        let url = URL(string: authString)
        var request = URLRequest(url: url!)
        request.httpMethod = "get"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let resultString = String(data: data, encoding: .utf8)!
            completion(resultString)
        }.resume()
    }
    
    func presentAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
