//
//  SecondViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CocoaLumberjack

class OrdersContainerViewController: UIViewController {
    
    private lazy var currentOrderViewController: CurrentOrderViewController = {
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "CurrentOrderVC") as! CurrentOrderViewController
        return viewController
    }()
    
    private lazy var previousOrdersViewController: PastOrdersViewController = {
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "PastOrdersVC") as! PastOrdersViewController
        return viewController
    }()
    
    private var currentChildVC: UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Update current view
        if let _ = UserUtil.currentUser!.currentOrder {
            // Show Current Order View
            if currentChildVC != currentOrderViewController {
                add(asChildViewController: currentOrderViewController)
                currentChildVC = currentOrderViewController
            }
        } else {
            // Show Past Orders View
            if currentChildVC != previousOrdersViewController {
                add(asChildViewController: previousOrdersViewController)
                currentChildVC = previousOrdersViewController
            }
        }
    }
    
    // MARK: - Container View Methods
    private func add(asChildViewController viewController: UIViewController) {
        if let currentChildVC = currentChildVC {
            remove(asChildViewController: currentChildVC)
        }
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

