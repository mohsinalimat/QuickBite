//
//  GetStartedViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/11/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import GoogleSignIn
import FirebaseAuth

class GetStartedViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
            if let _ = user {
                // If we have a user AND it's not a stale account, continue to the address selection page
                self.performSegue(withIdentifier: "AddNewAddressSegue", sender: nil)
            }
//            guard let _ = user?.uid else {
//                print("statechange called but no uid = not actually logged in? stale data somehow?")
//                return
//            }
//            print("Did log in and has uid!")
//            print(user?.uid)
//            print(user?.displayName)
//            print(user?.email)
//            print(user?.phoneNumber)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
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
