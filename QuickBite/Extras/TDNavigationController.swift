//
//  TDNavigationController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/22/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class TDNavigationController: UINavigationController {
    
    // For every viewController that gets pushed onto the stack,
    // save a boolean to determine whether or not a shadow was shown.
    // This should probably be removed later...
    private var shadowStack: [Bool] = []
    
    private var shadowIsShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = .systemBackground
            navBarAppearance.shadowColor = .clear

            self.navigationBar.standardAppearance = navBarAppearance
        } else {
            self.navigationBar.backgroundColor = .white
            self.navigationBar.shadowImage = UIImage()
        }
        
        self.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationBar.layer.shadowRadius = 5
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        shadowStack.append(shadowIsShown)
        shadowIsShown = false
        self.navigationBar.layer.shadowOpacity = 0
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        // Avoid unnecessary animation calls
        if let show = shadowStack.popLast() {
            showShadow(show)
        }
        return super.popViewController(animated: animated)
    }
    
    func showShadow(_ show: Bool) {
        guard show != shadowIsShown else { return }
        
        UIView.animate(withDuration: 0.12) {
            self.navigationBar.layer.shadowOpacity = show ? 0.25 : 0
        }
        shadowIsShown = show
    }
}
