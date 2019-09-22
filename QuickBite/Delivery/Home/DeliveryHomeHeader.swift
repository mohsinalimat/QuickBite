//
//  DeliveryHomeHeader.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/1/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class DeliveryHomeHeader: UIView {
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var shadowView: GradientView!
    
    var shadowIsShown = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("DeliveryHomeHeader", owner: self, options: nil)
        addSubview(masterView)
        masterView.frame = self.bounds
    }
    
    func setStreetLabel(_ streetString: String) {
        streetLabel.text = streetString
    }
    
    func showShadow(_ showShadow: Bool) {
        if shadowIsShown != showShadow {
            UIView.animate(withDuration: 0.1) {
//                self.shadowView.alpha = showShadow ? 1.0 : 0.0
            }
            shadowIsShown = showShadow
        }
    }
}
