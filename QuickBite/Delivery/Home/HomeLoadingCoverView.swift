//
//  HomeLoadingCoverView.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/16/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class HomeLoadingCoverView: UIView {
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HomeLoadingCoverView", owner: self, options: nil)
        addSubview(masterView)
        masterView.frame = self.bounds
        masterView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        activityIndicator.startAnimating()
    }
}
