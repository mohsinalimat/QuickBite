//
//  AccountViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import FirebaseFirestore
import GoogleSignIn
import FacebookLogin
import FirebaseAuth
import CocoaLumberjack

class AccountMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate {
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var signInView: UIView!
    
    private var accountMenuItems: [String] = [] // accidentally renamed lol
    
    private var loadingCoverView = LoadingCoverView(loadingText: "Setting up your account...")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = UserUtil.currentUser!
        
        updateUI(userIsGuest: currentUser.isGuest)
        
        var userName = currentUser.name
        
        if userName.isEmpty {
            userName = "Account Details"
        }
        
        accountMenuItems.append(userName + "|Change your account information")
        accountMenuItems.append("Addresses|Add or remove a delivery address")
        accountMenuItems.append("Notifications|")
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let selectionIndexPath = menuTableView.indexPathForSelectedRow {
            menuTableView.deselectRow(at: selectionIndexPath, animated: false)
        }
        
        updateNameMenuItem(newName: UserUtil.currentUser!.name)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let db = Firestore.firestore()
                
                // Check if a record already exists in the "users" collection
                let userDocRef = db.collection("users").document(user.uid)
                
                userDocRef.getDocument { (document, error) in
                    if let document = document, document.exists, let data = document.data() {
                        // EDGE CASE: The user has signed in with social media account before. This should be a rare case
                        let firebaseUser = User(dictionary: data)
                        UserUtil.updateCurrentUser(firebaseUser)
                        self.updateUI(userIsGuest: false)
                        self.updateNameMenuItem(newName: firebaseUser.name)
                        self.loadingCoverView.hide()
                    } else {
                        // MAIN CASE: User does not have an existing Firebase user.
                        // Create one from the existing information in their guest account

                        // If user has not set a name for their guest account, use the name from their social media.
                        // If that fails, remain blank.
                        DDLogDebug("Creating user...")
                        let currentUdUser = UserUtil.currentUser!
                        if currentUdUser.name.isEmpty {
                            currentUdUser.name = user.displayName ?? ""
                        }
                        currentUdUser.isGuest = false
                        UserUtil.updateCurrentUser(currentUdUser)
                        userDocRef.setData(currentUdUser.dictionary)
                        self.updateUI(userIsGuest: false)
                        self.updateNameMenuItem(newName: currentUdUser.name)
                        self.loadingCoverView.hide()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    private func updateUI(userIsGuest: Bool) {
        // Show/Hide Logout button and sign in view
        if userIsGuest {
            logOutButton.isHidden = true
            signInView.isHidden = false
        } else {
            signInView.isHidden = true
            logOutButton.isHidden = false
        }
    }
    
    private func updateNameMenuItem(newName: String) {
        if accountMenuItems[0].chompAt("|") != newName && newName.isNotEmpty {
            // name has been updated
            accountMenuItems[0] = newName + "|Change your account information"
            menuTableView.reloadData()
        }
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            AppManager.shared.logout()
        }))
        optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(optionMenu, animated: true, completion: nil)
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
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountMenuItemCell", for: indexPath) as! AccountMenuTableViewCell
        
        let menuItem = accountMenuItems[indexPath.row]
        
        cell.title.text = menuItem.chompAt("|")
        if menuItem.chompAfter("|").isNotEmpty {
            cell.subtitle.text = menuItem.chompAfter("|")
        } else if let subtitle = cell.subtitle { // I have absolutely no idea why this check is needed, but it crashes otherwise
            subtitle.removeFromSuperview()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // Account Information
            performSegue(withIdentifier: "ShowAccountInformationSegue", sender: nil)
        case 1: // Addresses
            performSegue(withIdentifier: "ShowAddressesSegue", sender: nil)
        case 2: // Notifications
            performSegue(withIdentifier: "ShowNotificationsSegue", sender: nil)
        default:
            return
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addressesVC = segue.destination as? AddressesViewController {
            addressesVC.settingsMode = true
        }
    }
}

class AccountMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}
