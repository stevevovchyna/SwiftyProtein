//
//  ListViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import Foundation

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    var ligands : [String] = ligandsArray
    var ligandToPass : Ligand?
    var infoToPass : [LigandInfo] = []
    let status = UIActivityIndicatorView()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        status.frame = CGRect(x: view.frame.size.width / 2, y:  view.frame.size.height / 2, width: 30, height: 30)
        status.style = .large
        self.view.addSubview(status)
        
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
        status.isHidden = false
        status.startAnimating()
        tableView.isUserInteractionEnabled = false
        requestLigand(forLigand: ligands[indexPath.row], atIndex: indexPath.row){ resultLigand in
            switch resultLigand {
            case .error(let err):
                self.presentAlert(text: err)
            case .success(let ligandOut):
                requestLigandInfo(forLigand: self.ligands[indexPath.row]){ info in
                    DispatchQueue.main.async {
                        self.infoToPass = info
                        self.ligandToPass = ligandOut
                        self.tableView.isUserInteractionEnabled = true
                        self.status.isHidden = true
                        self.status.stopAnimating()
                        tableView.deselectRow(at: indexPath, animated: true)
                        self.performSegue(withIdentifier: "showLigand", sender: self)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLigand" {
            let vc = segue.destination as! ProteinViewController
            vc.ligandToDisplay = ligandToPass
            vc.ligandInfo = infoToPass
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
    
    func presentAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
