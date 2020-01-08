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
    
    var ligandToDisplay: Ligand?
    var ligandNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "LigandInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "ligandInfo")
        tableView.separatorStyle = .none
        
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
    
    @IBAction func showAR(_ sender: UIBarButtonItem) {
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
    func sceneSetup() {
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
    }
}

