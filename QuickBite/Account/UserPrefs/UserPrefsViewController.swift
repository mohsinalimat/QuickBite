//
//  UserPrefsViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class UserPrefsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let userInfoLabels = ["Name", "Phone", "Email"]
    private let dummyValues = ["Griffin Smalley", "9171780373", ""]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell", for: indexPath) as! UserPrefsTableViewCell
        
        cell.userInfoLabel.text = userInfoLabels[indexPath.row]
        cell.userInfoTextField.text = dummyValues[indexPath.row]
        
        return cell
    }

}
