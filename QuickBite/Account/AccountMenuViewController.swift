//
//  AccountViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class AccountMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    private var accountMenuItems: [[String]] = [] // accidentally renamed lol

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var userName = UserUtil.currentUser!.name
        
        if userName.isEmpty {
            userName = "Account Details"
        }
        
        accountMenuItems.append([userName, "Change your account information"])
        accountMenuItems.append(["Addresses", "Add or remove a delivery address"])
        accountMenuItems.append(["Notifications", ""])
        accountMenuItems.append(["Log Out", ""])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let selectionIndexPath = menuTableView.indexPathForSelectedRow {
            menuTableView.deselectRow(at: selectionIndexPath, animated: false)
        }
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountMenuItemCell", for: indexPath) as! AccountMenuTableViewCell
        
        let menuItem = accountMenuItems[indexPath.row]
        
        cell.title.text = menuItem[0]
        if menuItem[1].isNotEmpty {
            cell.subtitle.text = menuItem[1]
        } else if let subtitle = cell.subtitle { // I have absolutely no idea why this check is needed, but it crashes otherwise
            subtitle.removeFromSuperview()
        }
        
        if menuItem[0] == "Log Out" {
            cell.accessoryType = .none
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
        case 3: // Log Out
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
