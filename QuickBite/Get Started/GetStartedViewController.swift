//
//  GetStartedViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/11/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth
import CocoaLumberjack

class GetStartedViewController: UIViewController, GIDSignInDelegate {
    var handle: AuthStateDidChangeListenerHandle?
    
    private var loadingCoverView = LoadingCoverView(loadingText: "Setting up your account...")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
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
                        udUser = User(name: user.displayName ?? "", isGuest: false)
                    }
                    // Set UserDefaults current user
                    UserUtil.updateCurrentUser(udUser)
                    self.loadingCoverView.hide() // In case the user comes back from AddNewAddress
                    if let addresses = UserUtil.currentUser?.addresses, !addresses.isEmpty {
                        self.performSegue(withIdentifier: "ShowMainDeliveryFromGetStarted", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "AddNewGoogleAddressSegue", sender: nil)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        DDLogDebug("didSignInForUser")
        if let error = error {
            DDLogError("Error in didSignInForUser: \(error)")
            return
        }
        
        loadingCoverView.cover(parentView: self.view, animated: true)
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Firebase log in
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error in authenticating with firebase: \(error)")
                return
            }
            // User is signed in
            DDLogDebug("Successfully signed user in to Firebase")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        DDLogDebug("didDisconnectWith")
    }
    
    @IBAction func googleSignInTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func continueWithoutAccountTapped(_ sender: Any) {
        UserUtil.updateCurrentUser(User(isGuest: true))
//        performSegue(withIdentifier: "AddNewAddressSegue", sender: nil)
        performSegue(withIdentifier: "AddNewGoogleAddressSegue", sender: nil)
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
