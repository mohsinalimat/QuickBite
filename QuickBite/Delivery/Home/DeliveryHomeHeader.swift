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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shadowView: GradientView!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    var isShown = true
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
        masterView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setStreetLabel(_ streetString: String) {
        streetLabel.text = streetString
    }
    
    func show(_ show: Bool) {
        if isShown != show {
            contentViewTopConstraint.constant = show ? 0 : -25
            UIView.animate(withDuration: 0.12) {
                self.masterView.alpha = show ? 1 : 0
                self.shadowView.alpha = (show && self.shadowIsShown) ? 1 : 0
                self.layoutIfNeeded()
            }
            isShown = show
            self.isUserInteractionEnabled = show
        }
    }
    
    func showShadow(_ showShadow: Bool) {
        if shadowIsShown != showShadow {
            UIView.animate(withDuration: 0.1) {
                self.shadowView.alpha = showShadow ? 1.0 : 0.0
            }
            shadowIsShown = showShadow
        }
    }
}
