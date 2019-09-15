//
//  SignInSignUpViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/11/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class SignInSignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.white), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
