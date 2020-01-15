//
//  LigandInfoTableViewCell.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 05.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit

class LigandInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ligandLabel: UILabel!
    @IBOutlet weak var ligandText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        ligandLabel.backgroundColor = .black
        ligandLabel.textColor = .white
        ligandLabel.layer.masksToBounds = true
        ligandLabel.layer.cornerRadius = 5
    }    
}
