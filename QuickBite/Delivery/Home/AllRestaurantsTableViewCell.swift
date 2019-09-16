//
//  RestaurantTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/26/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class AllRestaurantsTableViewCell: UITableViewCell {
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantCategories: UILabel!
    @IBOutlet weak var restaurantRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
