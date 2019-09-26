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
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var selectedItemOptions: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
