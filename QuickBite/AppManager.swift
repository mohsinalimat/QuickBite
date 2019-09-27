//
//  AppManager.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/14/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import Firebase

class AppManager {
    static let shared = AppManager()
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    private init() { }
    
    var appContainer: AppContainerViewController!
    
    func showApp() {
        var viewController: UIViewController
        if let user = UserUtil.currentUser, !user.addresses.isEmpty {
            viewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
        }
        appContainer.present(viewController, animated: false, completion: nil)
    }
    
    func logout() {
        Cart.empty()
        UserUtil.clearCurrentUser()
        try! Auth.auth().signOut()
        self.appContainer.dismiss(animated: false, completion: nil)
    }
    
    func resetVCStack() {
        self.appContainer.dismiss(animated: true, completion: nil)
    }
}

