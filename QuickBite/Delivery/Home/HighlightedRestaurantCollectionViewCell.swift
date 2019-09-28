//
//  RestaurantCollectionViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/26/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class HighlightedRestaurantCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAndDeliveryFee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
