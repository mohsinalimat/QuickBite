//
//  CartBanner.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/29/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton

class CartBanner: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var button: PMSuperButton!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CartBanner", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        updateLabels()
    }
    
    func updateLabels() {
        let cartItemCount = Cart.totalQuantity
        itemCountLabel.text = cartItemCount == 1 ? "1 item" : "\(cartItemCount) items"
        
        totalPriceLabel.text = Cart.totalPrice.asPriceString
    }
    
}
