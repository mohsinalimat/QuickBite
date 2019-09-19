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
import CocoaLumberjack

class GetStartedViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    private var shouldShowLoadingOnReappear: Bool = false
    private var loadingCoverView = LoadingCoverView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(userCancelledLogin(_:)), name: .userCancelledLogin, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DDLogDebug("ViewWillAppear")
        if shouldShowLoadingOnReappear {
            DDLogDebug("Showing loading cover view")
            loadingCoverView.cover(parentView: self.view)
        }
        
        // Not sure why this doesn't work in viewDidLoad but it doesn't
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
                self.shouldShowLoadingOnReappear = false
                self.performSegue(withIdentifier: "AddNewAddressSegue", sender: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowLoadingOnReappear == false {
            loadingCoverView.hide()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @objc private func userCancelledLogin(_ notif: Notification) {
        shouldShowLoadingOnReappear = false
    }
    
    @IBAction func googleSignInTapped(_ sender: Any) {
        shouldShowLoadingOnReappear = true
        GIDSignIn.sharedInstance()?.signIn()
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
