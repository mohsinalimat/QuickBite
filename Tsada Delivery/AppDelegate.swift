//
//  AppDelegate.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookCore
import FirebaseAuth
import CocoaLumberjack
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private final let APP_FIRST_OPEN = "APP_FIRST_OPEN"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // CocoaLumberjack
        DDLog.add(DDOSLogger.sharedInstance)
        DDOSLogger.sharedInstance.logFormatter = CustomFormatter()
        
        // Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // Firebase stores login sessions in the keychain, which is NOT deleted when the user uninstalls the app.
        // So, if a user is logged in, then uninstalls and re-installs the app, the default Firebase behavior would automatically
        // log them in again. This code modifies that terrible default behavior by using a trivial UserDefaults boolean to
        // track whether or not this is the first time the app has been opened and to log out any old sessions if so.
        if UserDefaults.standard.bool(forKey: APP_FIRST_OPEN) == false {
            // App has not been opened before, log out the old firebase session if there is one
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                // The signout will fail if this the absolute first time the app was ran on this user's device. That's okay.
                print ("Error signing out: \(signOutError)")
            }
            UserDefaults.standard.set(true, forKey: APP_FIRST_OPEN)
        }
        
        GMSServices.provideAPIKey("AIzaSyDA9qrmg1UNFPnlAZWC1Xlis5TdkNIzavM")
        GMSPlacesClient.provideAPIKey("AIzaSyDA9qrmg1UNFPnlAZWC1Xlis5TdkNIzavM")
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let fbHandled = ApplicationDelegate.shared.application(application, open: url, options: options)
        return GIDSignIn.sharedInstance().handle(url) || fbHandled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

