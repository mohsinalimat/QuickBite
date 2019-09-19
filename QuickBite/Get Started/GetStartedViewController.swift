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
    private var loadingCoverView = LoadingCoverView(loadingText: "Setting up your account...")
    
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
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // Download
                let db = Firestore.firestore()
                
                // Check if a record already exists in the "users" collection
                let userDocRef = db.collection("users").document(user.uid)
                
                userDocRef.getDocument { (document, error) in
                    var udUser: User!
                    if let document = document, document.exists, let data = document.data() {
                        // User exists
                        udUser = User(dictionary: data)
                    } else {
                        // User does not exist, so we should create one
                        DDLogDebug("Creating user...")
                        userDocRef.setData([
                            "name": user.displayName ?? ""
                            ])
                        udUser = User(name: user.displayName ?? "")
                    }
                    // Set UserDefaults current user
                    UserUtil.setCurrentUser(udUser)
                    
                    self.shouldShowLoadingOnReappear = false
                    if let addresses = UserUtil.currentUser?.addresses, !addresses.isEmpty {
                        self.performSegue(withIdentifier: "ShowMainDeliveryFromGetStarted", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "AddNewAddressSegue", sender: nil)
                    }
                }
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
