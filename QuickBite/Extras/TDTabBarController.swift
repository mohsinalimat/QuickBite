//
//  QBTabBarController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/30/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class TDTabBarController: UITabBarController, MenuItemViewControllerDelegate {
    
    private let cartBanner = CartBanner()
    private var cartBannerIsShown = false
    private var cartBottomAnchor = NSLayoutConstraint()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add subview offscreen, to be animated in once an item is added
        view!.addSubview(cartBanner)
        
        cartBanner.translatesAutoresizingMaskIntoConstraints = false
        cartBanner.centerXAnchor.constraint(equalTo: view!.centerXAnchor).isActive = true
        cartBanner.leftAnchor.constraint(equalTo: view!.leftAnchor, constant: 30).isActive = true
        cartBanner.rightAnchor.constraint(equalTo: view!.rightAnchor, constant: -30).isActive = true
        cartBanner.heightAnchor.constraint(equalToConstant: 55).isActive = true
        cartBottomAnchor = cartBanner.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 100)
        cartBottomAnchor.isActive = true
        
        cartBanner.button.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        
        view!.bringSubviewToFront(tabBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showCartBanner()
        if UserDefaults.standard.bool(forKey: UDKeys.redirectToOrders) {
            self.selectedIndex = 1
            UserDefaults.standard.removeObject(forKey: UDKeys.redirectToOrders)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        showCartBanner(item.title == "Delivery", withSpring: false)
    }
    
    func showCartBanner(_ showOverride: Bool = true, animated: Bool = true, withSpring: Bool = true) {
        if showOverride && Cart.hasItems {
            cartBanner.updateLabels()
            cartBanner.layoutIfNeeded() // Avoids a strange visual bug with the total price label...
            
            if !cartBannerIsShown {
                self.view!.layoutIfNeeded()
                cartBottomAnchor.constant = -8
                view!.setNeedsUpdateConstraints()
                let duration = animated ? 0.4 : 0.0
                if withSpring {
                    UIView.animate(withDuration: duration, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 9.5, options: .curveEaseOut, animations: {
                        self.view!.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseInOut], animations: {
                        self.view!.layoutIfNeeded()
                    })
                }
                cartBannerIsShown = true
            }
        } else {
            cartBottomAnchor.constant = 100
            cartBannerIsShown = false
        }
    }
    
    @objc func cartTapped() {
        let storyboard = UIStoryboard(name: "Delivery", bundle: nil)
        let cartNavigationController = storyboard.instantiateViewController(withIdentifier: "CartNavigationController") as! UINavigationController
        present(cartNavigationController, animated: true, completion: nil)
    }
    
    // MARK: - MenuItemViewControllerDelegate
    func itemAddedToCart() {
        showCartBanner()
    }
}
