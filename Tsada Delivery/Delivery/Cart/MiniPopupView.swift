//
//  MiniPopupView.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/20/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class MiniPopupView: UIView {
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MiniPopupView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.alpha = 0
    }
    
    func show() {
        let originalFrameY = contentView.frame.origin.y
        contentView.frame.origin.y += 7
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.contentView.frame.origin.y = originalFrameY
            self.contentView.alpha = 1.0
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 0.0
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
