//
//  NavBarShadow.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/23/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class NavBarShadow: UIView {
    @IBOutlet var masterView: GradientView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init(loadingText: String = "") {
        self.init(frame: CGRect.zero)
        commonInit(loadingText)
    }
    
    private func commonInit(_ loadingText: String = "") {
        Bundle.main.loadNibNamed("NavBarShadow", owner: self, options: nil)
        addSubview(masterView)
        masterView.frame = self.bounds
        masterView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
