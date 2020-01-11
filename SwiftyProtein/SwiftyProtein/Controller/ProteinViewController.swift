//
//  ProteinViewController.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 23.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class ProteinViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var reloadSceneButton: UIButton!
    @IBOutlet weak var showARViewButton: UIButton!
    
    
    var ligandToDisplay: Ligand?
    var ligandNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "LigandInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "ligandInfo")
        tableView.separatorStyle = .none
        
        viewColorsSetup()
        sceneSetup()
        ligandSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                guard let tappedNode = hits.first?.node else { return }
                let node = atomNameNode(for: tappedNode)
                sceneView.scene?.rootNode.addChildNode(node)
            }
        }
    }
    
    @IBAction func showAR(_ sender: UIButton) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            performSegue(withIdentifier: "showAR", sender: self)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.performSegue(withIdentifier: "showAR", sender: self)
                } else {
                    presentAlert(text: "No camera Access", in: self)
                }
            })
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Share your modelization!", message: "Enter any text to share your modelization", preferredStyle: .alert)
        guard let ligand = ligandToDisplay else { return }
        alert.addTextField { textField in
            textField.text = "Check out my visualization of \(ligand.name)"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Share", style: .default) { [weak alert] (_) in
            let text = alert?.textFields![0].text
            let image = self.sceneView.snapshot()
            var finalArray : [Any] = [image]
            if text != "" { finalArray.append(text ?? "") }
            let activityViewController = UIActivityViewController(activityItems: finalArray, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.sceneView
            self.present(activityViewController, animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refreshScene(_ sender: UIButton) {
        ligandNode = SCNNode()
        sceneSetup()
        if let ligand = ligandToDisplay {
            ligandNode = ligand.createLigandNode()
            sceneView.scene!.rootNode.addChildNode(ligandNode)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
            sceneView.addGestureRecognizer(tap)
        } else {
            presentAlert(text: "There was a problem creating your ligand", in: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ARViewController
        vc.ligandToDisplay = ligandToDisplay
    }
}

extension ProteinViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let info = ligandToDisplay?.info {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ligandInfo", for: indexPath) as! LigandInfoTableViewCell
            cell.backgroundColor = .clear
            cell.ligandNameLabel.text = "Name"
            cell.ligandName.text = info.name
            cell.identifiersLabel.text = "Identifiers"
            cell.identifiers.text = info.identifiers
            cell.formulaLabel.text = "Formula"
            cell.formula.text = info.formula
            cell.molecularWeightLabel.text = "Molecular Weight"
            cell.molecularWeight.text = info.formulaWeight
            cell.typeLabel.text = "Type"
            cell.type.text = info.type
            cell.isometricSmilesLabel.text = "Isometric Smiles"
            cell.isometricSmiles.text = info.smiles
            cell.InChlLabel.text = "InChl"
            cell.InChl.text = info.inchi
            cell.InChIKeyLabel.text = "InChl Key"
            cell.InChIKey.text = info.inchiKey
            cell.formalChargeLabel.text = "Formal Charge"
            cell.formalCharge.text = info.formalCharge
            cell.atomCountLabel.text = "Atom Count"
            cell.atomCount.text = info.atomCount
            cell.chiralAtomCountLabel.text = "Chiral Atom Count"
            cell.chiralAtomCount.text = info.chiralAtomCount
            cell.chiralAtomsLabel.text = "Chiral Atoms"
            cell.chiralAtoms.text = info.chiralAtomsStr
            cell.boundCountLabel.text = "Bound Count"
            cell.boundCount.text = info.bondCount
            cell.aromaticBoundCountLabel.text = "Aromatic Bound Count"
            cell.aromaticBoundCount.text = info.aromaticBondCount
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath)
            cell.textLabel?.text = "No data available"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}

extension ProteinViewController {
    private func sceneSetup() {
        let scene = SCNScene()
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
      
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLight.LightType.omni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
      
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 20)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.scene = scene
        sceneView.backgroundColor = .clear
    }
    
    private func viewColorsSetup() {
        setGradientBackground(forViewController: self.view)
        tableView.backgroundColor = .clear
        self.reloadSceneButton.layer.cornerRadius = 5
        self.reloadSceneButton.backgroundColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 0.25)
        self.showARViewButton.layer.cornerRadius = 5
        self.showARViewButton.backgroundColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 0.25)
    }
    
    private func ligandSetup() {
        if let ligand = self.ligandToDisplay {
            self.navigationItem.title = ligand.name
            self.ligandNode = ligand.createLigandNode()
            self.sceneView.scene!.rootNode.addChildNode(ligandNode)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
            self.sceneView.addGestureRecognizer(tap)
        } else {
            presentAlert(text: "There was a problem creating your ligand", in: self)
        }
    }
}

