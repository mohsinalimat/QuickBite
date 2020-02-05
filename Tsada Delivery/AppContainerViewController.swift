//
//  AppContainerViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/14/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class AppContainerViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppManager.shared.appContainer = self
        AppManager.shared.showApp()
    }
}
