//
//  PastOrderMenuItemTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/26/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class PreviousOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var orderItemsMasterStackView: UIStackView!
    @IBOutlet weak var firstOrderItemStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setMenuItems(_ menuItems: [MenuItem]) {
        let firstMenuItem = menuItems.first!
        firstOrderItemStackView.setQuantityLabel(firstMenuItem.selectedQuantity)
        firstOrderItemStackView.setMenuItemLabel(firstMenuItem.itemName)
        
        for item in menuItems.dropFirst() {
            let newOrderItemStackView = firstOrderItemStackView.copy() as! UIStackView
            newOrderItemStackView.setQuantityLabel(item.selectedQuantity)
            newOrderItemStackView.setMenuItemLabel(item.itemName)
            orderItemsMasterStackView.addArrangedSubview(newOrderItemStackView)
        }
    }
}

extension UIStackView {
    func setQuantityLabel(_ quantity: Int) {
        guard let firstView = self.arrangedSubviews.first,
            let quantityLabel = firstView as? UILabel else {
            print("meep")
            return
        }
        
        quantityLabel.text = "\(String(quantity))x"
    }
    
    func setMenuItemLabel(_ menuItemName: String) {
        guard let firstView = self.arrangedSubviews.first,
            let menuItemLabel = firstView as? UILabel else {
            print("moop")
            return
        }
        
        menuItemLabel.text = menuItemName
    }
}
