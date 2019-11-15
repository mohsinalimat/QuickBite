//
//  OrderOptionHeaderView.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/28/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class OrderOptionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: self)
    
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    @IBOutlet weak var orderOptionsTitle: UILabel!
    @IBOutlet weak var requiredLabel: UILabel!
    
    var isSingleSelection = true        // Whether or not multiple options can be selected
    var selectionIsRequired: Bool = false { // Whether or not a selection for this option is required to place an order
        didSet {
            requiredLabel.alpha = self.selectionIsRequired ? 1.0 : 0.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        requiredLabel.font = requiredLabel.font.smallCaps()
    }
    
    func requirementIsSatisfied() {
        guard !requiredLabel.text!.contains("✓") else { return } // Avoid duplicate animations
        self.requiredLabel.textColor = #colorLiteral(red: 0, green: 0.8491616455, blue: 0.4379607217, alpha: 1)
        self.requiredLabel.text = "✓ REQUIRED"
    }
}
