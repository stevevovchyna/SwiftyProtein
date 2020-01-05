//
//  LigandInfoTableViewCell.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 05.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit

class LigandInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var ligandNameLabel: UILabel!
    @IBOutlet weak var ligandName: UILabel!
    @IBOutlet weak var identifiersLabel: UILabel!
    @IBOutlet weak var identifiers: UILabel!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var formula: UILabel!
    @IBOutlet weak var molecularWeightLabel: UILabel!
    @IBOutlet weak var molecularWeight: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var isometricSmilesLabel: UILabel!
    @IBOutlet weak var isometricSmiles: UILabel!
    @IBOutlet weak var InChlLabel: UILabel!
    @IBOutlet weak var InChl: UILabel!
    @IBOutlet weak var InChIKeyLabel: UILabel!
    @IBOutlet weak var InChIKey: UILabel!
    @IBOutlet weak var formalChargeLabel: UILabel!
    @IBOutlet weak var formalCharge: UILabel!
    @IBOutlet weak var atomCount: UILabel!
    @IBOutlet weak var atomCountLabel: UILabel!
    @IBOutlet weak var chiralAtomCountLabel: UILabel!
    @IBOutlet weak var chiralAtomCount: UILabel!
    @IBOutlet weak var chiralAtomsLabel: UILabel!
    @IBOutlet weak var chiralAtoms: UILabel!
    @IBOutlet weak var boundCountLabel: UILabel!
    @IBOutlet weak var boundCount: UILabel!
    @IBOutlet weak var aromaticBoundCountLabel: UILabel!
    @IBOutlet weak var aromaticBoundCount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let labelsArray = [ligandNameLabel, identifiersLabel, formulaLabel, molecularWeightLabel, typeLabel, isometricSmilesLabel, InChlLabel, InChIKeyLabel, formalChargeLabel, atomCountLabel, chiralAtomsLabel, chiralAtomCountLabel, boundCountLabel, aromaticBoundCountLabel]
        getRoundedBorders(forLabels: labelsArray as! [UILabel])
    }
    
    func getRoundedBorders(forLabels labels: [UILabel]) {
        for label in labels {
            label.backgroundColor = .gray
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 5
        }
    }
    
}
