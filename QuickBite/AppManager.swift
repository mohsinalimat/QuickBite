//
//  AppManager.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/14/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import Firebase
import Hero

class AppManager {
    static let shared = AppManager()
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    private init() { }
    
    var appContainer: AppContainerViewController!
    
    func showApp() {
        var viewController: UIViewController
        if let _ = Auth.auth().currentUser {
            viewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
        }
        viewController.hero.modalAnimationType = .fade
        appContainer.present(viewController, animated: true, completion: nil)
    }
    
    func logout() {
        try! Auth.auth().signOut()
        self.appContainer.dismiss(animated: false, completion: nil)
    }
}

