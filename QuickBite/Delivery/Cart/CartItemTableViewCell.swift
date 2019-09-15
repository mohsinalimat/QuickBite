//
//  CartItemTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/30/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class CartItemTableViewCell: UITableViewCell {
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var selectedItemOptions: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
