//
//  AccountViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    private var menuItems = [[String]]() // accidentally renamed lol

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        menuItems.append(["Griffin Smalley", "Change your account information"])
        menuItems.append(["Addresses", "Add or remove a delivery address"])
        menuItems.append(["Notifications"])
        menuItems.append(["Support Center"])
        menuItems.append(["Log Out"])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let selectionIndexPath = menuTableView.indexPathForSelectedRow {
            menuTableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountIdentifier", for: indexPath) as! AccountTableViewCell
        cell.mainTitle.text = menuItems[indexPath.row][0]
        if menuItems[indexPath.row].count != 1 {
            cell.subtitle.text = menuItems[indexPath.row][1]
        } else {
            cell.subtitle.removeFromSuperview()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // User Prefs
            performSegue(withIdentifier: "ShowUserPrefsSegue", sender: nil)
        case 1: // Addresses
            performSegue(withIdentifier: "ShowAddressesSegue", sender: nil)
        case 2: // Notifications
            performSegue(withIdentifier: "ShowUserPrefsSegue", sender: nil)
        case 4: // Log Out
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            optionMenu.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                AppManager.shared.logout()
            }))
            optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(optionMenu, animated: true, completion: nil)
        default:
            return
        }
    }
}
