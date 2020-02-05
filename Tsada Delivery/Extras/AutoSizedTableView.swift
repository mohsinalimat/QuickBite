//
//  AutoSizedTableView.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/28/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import UIKit

final class AutoSizedTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
