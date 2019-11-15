//
//  PastOrderMenuItemTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/26/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class PastOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var orderItemsMasterStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setMenuItems(_ menuItems: [MenuItem]) {
        for item in menuItems {
            let stackView = UIStackView()
            stackView.setup(quantity: item.selectedQuantity, menuItemName: item.itemName)
            orderItemsMasterStackView.addArrangedSubview(stackView)
        }
    }
}

extension UIStackView {
    func setup(quantity: Int, menuItemName: String) {
        self.axis = .horizontal
        self.alignment = .fill
        self.distribution = .fill
        
        let quantityLabel = UILabel()
        quantityLabel.font = .systemFont(ofSize: 15, weight: .medium)
        quantityLabel.textColor = .secondaryLabelCompat
        quantityLabel.text = String(quantity) + "x"
        self.addArrangedSubview(quantityLabel)
        
        let menuItemLabel = UILabel()
        menuItemLabel.textColor = .secondaryLabelCompat
        menuItemLabel.font = .systemFont(ofSize: 15)
        menuItemLabel.text = menuItemName
        menuItemLabel.numberOfLines = 2
        self.addArrangedSubview(menuItemLabel)
        
        quantityLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
}
