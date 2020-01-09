//
//  Utils.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 07.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import ARKit

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

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
    var element : Element? = nil
    if let name = tappedNode.name {
        let elementInfo = getElementInfo(for: name)
        switch elementInfo {
        case .error:
            return SCNNode()
        case .success(let el):
            element = el
        }
    } else {
        return SCNNode()
    }
    if let element = element {
    
        let box = SCNBox(width: 0.95, height: 0.95, length: 0.05, chamferRadius: 0)
        let rectangleMaterial = SCNMaterial()
        rectangleMaterial.diffuse.contents = tappedNode.geometry?.firstMaterial?.diffuse.contents
        box.materials = [rectangleMaterial]
        let node = SCNNode()
        let pos = tappedNode.position
        node.position = SCNVector3(pos.x + 0.5, pos.y + 0.5, pos.z + 0.5)
        node.geometry = box

        let textColor = rectangleMaterial.diffuse.contents as! UIColor == UIColor.black ? UIColor.white : UIColor.black
        let labelNode = createSceneTextNode(with: element.name, color: textColor, 0.40, 0.22, 0.005, fontSize: 10)
        let bigElementNode = createSceneTextNode(with: element.symbol, color: textColor, 0.40, 0.08, 0.005, fontSize: 30)
        let numberNode = createSceneTextNode(with: String(element.number), color: textColor, 0.40, -0.25, 0.005, fontSize: 12)
        let atomicMassNode = createSceneTextNode(with: String(element.atomicMass), color: textColor, 0.40, 0.4, 0.005, fontSize: 12)
            
        node.addChildNode(labelNode)
        node.addChildNode(bigElementNode)
        node.addChildNode(numberNode)
        node.addChildNode(atomicMassNode)
        
        return node
    } else {
        return SCNNode()
    }
}

func createSceneTextNode(with text: String, color: UIColor, _ x: Float, _ y: Float, _ z: Float, fontSize: CGFloat) -> SCNNode {
    let text = SCNText(string: text, extrusionDepth: 5)
    text.font = UIFont(name: "Helvetica", size: fontSize)

    let material = SCNMaterial()
    
    material.diffuse.contents = color
    text.materials = [material]
    
    let textNode = SCNNode()
    
    textNode.scale = SCNVector3(0.01, 0.01, 0.01)
    
    textNode.position.x -= x
    textNode.position.y -= y
    textNode.position.z += z
    textNode.geometry = text
    
    return textNode
}
