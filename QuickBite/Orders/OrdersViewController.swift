//
//  SecondViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController, CurrentOrderViewDelegate {
    
    
    @IBOutlet weak var masterContentView: UIView!
    
    private var currentOrderView: CurrentOrderView!
    
    private lazy var pastOrdersViewController: PastOrdersViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Orders", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "PastOrdersViewController") as! PastOrdersViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if false {
            // Show Current Order View
            currentOrderView = CurrentOrderView()
            masterContentView.addSubviewAndFill(currentOrderView)
        } else {
            // Show Past Orders View
            add(asChildViewController: pastOrdersViewController)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        view.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    // MARK: - Current Order View Delegate
    
    func viewPastOrdersTapped() {
        performSegue(withIdentifier: "ShowPastOrdersSegue", sender: nil)
    }
    
    func contactUsTapped() {
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pastOrderVC = segue.destination as? PastOrdersViewController {
            pastOrderVC.showBigTitle = false
        }
    }
}

