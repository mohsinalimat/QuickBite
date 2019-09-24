//
//  SecondViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController {
    @IBOutlet weak var masterContentView: UIView!
    
    private var currentOrderView: CurrentOrderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentOrderView = CurrentOrderView()
        masterContentView.addSubviewAndFill(currentOrderView)
    }
}

