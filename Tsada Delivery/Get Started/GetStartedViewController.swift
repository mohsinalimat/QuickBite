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
import FacebookLogin
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
        
        // KEEP THIS CODE IN SYNC WITH ACCOUNTMENUVIEWCONTROLLER
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
                            "userName": user.displayName ?? ""
                            ])
                        udUser = User(name: user.displayName ?? "", isGuest: false)
                    }
                    // Set UserDefaults current user
                    UserUtil.updateCurrentUser(udUser)
                    self.loadingCoverView.hide() // In case the user comes back from AddNewAddress
                    if udUser.addresses.isEmpty {
                        self.performSegue(withIdentifier: "AddNewGoogleAddressSegue", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "ShowMainDeliveryFromGetStarted", sender: nil)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Google Sign In
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
        firebaseSignIn(credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        DDLogDebug("didDisconnectWith")
    }
    
    @IBAction func googleSignInTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: - Facebook Sign In
    @IBAction func facebookSignInTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(
            permissions: [.publicProfile, .email],
            viewController: self
        ) { result in
            self.fbLoginManagerDidComplete(result)
        }
    }
    
    private func fbLoginManagerDidComplete(_ result: LoginResult) {
        switch result {
        case .failed:
            DDLogError("facebook login failed")
            let alert = UIAlertController(title: "Error Logging In",
                                          message: "Unable to log in with Facebook. Please try again or log in using a different method.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        case .cancelled:
            DDLogWarn("facebook login cancelled")
        case .success:
            DDLogDebug("facebook login success!")
            loadingCoverView.cover(parentView: self.view, animated: true)
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            firebaseSignIn(credential)
        }
    }
    
    private func firebaseSignIn(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error in authenticating with firebase: \(error)")
                return
            }
            // User is signed in
            DDLogDebug("Successfully signed user in to Firebase")
        }
    }
    
    @IBAction func continueWithoutAccountTapped(_ sender: Any) {
        UserUtil.updateCurrentUser(User(isGuest: true))
        performSegue(withIdentifier: "AddNewGoogleAddressSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addNewAddressSearchVC = segue.destination as? AddNewAddressSearchViewController {
            addNewAddressSearchVC.firstTimeSetupMode = true
        }
    }
}
