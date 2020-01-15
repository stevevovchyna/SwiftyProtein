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

    
    var ligands : [String] = []
    var allLigands : [String] = []
    var ligandToPass : Ligand?
    let status = UIActivityIndicatorView()
    let downloadManager = DownloadManager()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColor()
        let parsedLigands = parseLigandFile()
        switch parsedLigands {
        case .success(let ligandsArray):
            ligands = ligandsArray
            allLigands = ligandsArray
        case .error(let err):
            fatalError(err)
        }
        addStatusLabel()
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
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeTableViewAcessibility(toActive: false, forRowAt: indexPath, in: tableView, in: status)
        downloadManager.requestLigandDataNInfo(forLigand: ligands[indexPath.row], atIndex: indexPath.row) { result in
            switch result {
            case .error(let err):
                presentAlert(text: err, in: self)
                changeTableViewAcessibility(toActive: true, forRowAt: indexPath, in: tableView, in: self.status)
            case .success(let ligand):
                self.ligandToPass = ligand
                changeTableViewAcessibility(toActive: true, forRowAt: indexPath, in: tableView, in: self.status)
                self.performSegue(withIdentifier: "showLigand", sender: self)
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
            ligands = allLigands
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            ligands = allLigands.filter { $0.lowercased().contains(searchText.lowercased()) }
            tableView.reloadData()
        }
    }
}

// MARK:- private methods

extension ListViewController {
    
    private func addStatusLabel() {
        status.frame = CGRect(x: (view.frame.size.width - 75) / 2, y:  (view.frame.size.height - 75) / 2, width: 75, height: 75)
        status.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.3102793237)
        status.layer.cornerRadius = 10
        status.style = .large
        
        self.view.addSubview(status)
    }
    
    private func setupColor() {
        self.tableView.backgroundColor = .clear
        setGradientBackground(forViewController: self.view)
    }
    
}
