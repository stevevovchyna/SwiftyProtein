//
//  Utils.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 07.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import ARKit

func presentAlert(text: String, in view: UIViewController) {
    let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
    view.present(alert, animated: true, completion: nil)
}

func changeTableViewAcessibility(toActive trigger: Bool, forRowAt row : IndexPath, in tableView: UITableView, in status: UIActivityIndicatorView) {
    status.isHidden = trigger
    trigger ? status.stopAnimating() : status.startAnimating()
    if trigger { tableView.deselectRow(at: row, animated: true) }
    tableView.isUserInteractionEnabled = trigger
}


func atomNameNode(for tappedNode: SCNNode) -> SCNNode {
    let text = SCNText(string: tappedNode.name, extrusionDepth: 2)
    let material = SCNMaterial()
    material.diffuse.contents = tappedNode.geometry?.firstMaterial?.diffuse.contents
    text.materials = [material]
    let node = SCNNode()
    let pos = tappedNode.position
    node.position = SCNVector3(pos.x + 0.05, pos.y + 0.05, pos.z + 0.05)
    node.scale = SCNVector3(0.05, 0.05, 0.05)
    node.geometry = text
    return node
}
