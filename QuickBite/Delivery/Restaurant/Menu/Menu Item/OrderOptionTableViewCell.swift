//
//  OrderOptionTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/28/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import BEMCheckBox

class OrderOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkbox.onAnimationType = .fill
        checkbox.offAnimationType = .fill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Avoid duplicate animation
        if checkbox.on != selected {
            checkbox.setOn(selected, animated: true)
        }
    }
}
