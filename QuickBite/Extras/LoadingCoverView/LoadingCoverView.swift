//
//  HomeLoadingCoverView.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/16/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingCoverView: UIView {
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
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
        Bundle.main.loadNibNamed("LoadingCoverView", owner: self, options: nil)
        addSubview(masterView)
        masterView.frame = self.bounds
        masterView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        activityIndicator.startAnimating()
        
        if loadingText.isNotEmpty {
            label.text = loadingText
        } else {
            label.removeFromSuperview()
        }
    }
    
    func cover(parentView: UIView, animated: Bool = false) {
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        UIView.animate(withDuration: (animated ? 0.5 : 0)) {
            self.alpha = 1.0
        }
    }
    
    func hide(animated: Bool = true) {
        UIView.animate(withDuration: (animated ? 0.5 : 0), animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
