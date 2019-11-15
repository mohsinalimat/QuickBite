//
//  FeaturedItemCollectionViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/26/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class FeaturedItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
