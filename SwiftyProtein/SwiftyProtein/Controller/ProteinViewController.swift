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
    var ligandToDisplay: Ligand?
    var ligandInfo : [LigandInfo] = []
    @IBOutlet weak var sceneView: SCNView!
    
    var geometryNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "LigandInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "ligandInfo")
        tableView.separatorStyle = .none
        sceneSetup()
        guard let ligand = ligandToDisplay else { return }
        geometryNode = addLigandAtoms(ligand: ligand)
        sceneView.scene!.rootNode.addChildNode(geometryNode)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                guard let tappedNode = hits.first?.node else { return }
                let text = SCNText(string: tappedNode.name, extrusionDepth: 2)
                let material = SCNMaterial()
                material.diffuse.contents = tappedNode.geometry?.firstMaterial?.diffuse.contents
                text.materials = [material]
                let node = SCNNode()
                let pos = tappedNode.position
                node.position = SCNVector3(pos.x + 0.05, pos.y + 0.05, pos.z + 0.05)
                node.scale = SCNVector3(0.05, 0.05, 0.05)
                node.geometry = text
                sceneView.scene?.rootNode.addChildNode(node)
            }
        }
    }
    
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
    
    @IBAction func showAR(_ sender: UIBarButtonItem) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            performSegue(withIdentifier: "showAR", sender: self)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.performSegue(withIdentifier: "showAR", sender: self)
                } else {
                    self.presentAlert(text: "No camera Access")
                }
            })
        }
        performSegue(withIdentifier: "showAR", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ARViewController
        vc.ligandToDisplay = ligandToDisplay
    }
    
    func presentAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ProteinViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandInfo", for: indexPath) as! LigandInfoTableViewCell
        cell.ligandNameLabel.text = "Name"
        cell.ligandName.text = ligandInfo[0].name
        cell.identifiersLabel.text = "Identifiers"
        cell.identifiers.text = ligandInfo[0].identifiers
        cell.formulaLabel.text = "Formula"
        cell.formula.text = ligandInfo[0].formula
        cell.molecularWeightLabel.text = "Molecular Weight"
        cell.molecularWeight.text = ligandInfo[0].formulaWeight
        cell.typeLabel.text = "Type"
        cell.type.text = ligandInfo[0].type
        cell.isometricSmilesLabel.text = "Isometric Smiles"
        cell.isometricSmiles.text = ligandInfo[0].smiles
        cell.InChlLabel.text = "InChl"
        cell.InChl.text = ligandInfo[0].inchi
        cell.InChIKeyLabel.text = "InChl Key"
        cell.InChIKey.text = ligandInfo[0].inchiKey
        cell.formalChargeLabel.text = "Formal Charge"
        cell.formalCharge.text = ligandInfo[0].formalCharge
        cell.atomCountLabel.text = "Atom Count"
        cell.atomCount.text = ligandInfo[0].atomCount
        cell.chiralAtomCountLabel.text = "Chiral Atom Count"
        cell.chiralAtomCount.text = ligandInfo[0].chiralAtomCount
        cell.chiralAtomsLabel.text = "Chiral Atoms"
        cell.chiralAtoms.text = ligandInfo[0].chiralAtomsStr
        cell.boundCountLabel.text = "Bound Count"
        cell.boundCount.text = ligandInfo[0].bondCount
        cell.aromaticBoundCountLabel.text = "Aromatic Bound Count"
        cell.aromaticBoundCount.text = ligandInfo[0].aromaticBondCount
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}

