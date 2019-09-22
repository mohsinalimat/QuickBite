//
//  MenuTableViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    var menuItemsForCategory: [MenuItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset.top = 10
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsForCategory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemTableViewCell

        let menuItem = menuItemsForCategory[indexPath.row]
        if menuItem.imageURL.isNotEmpty {
            cell.menuItemImage.sd_setImage(with: URL(string: menuItem.imageURL))
        } else {
            cell.imageHeightConstraint.constant = 0
        }
        cell.menuItemName.text = menuItem.itemName
        cell.menuItemDescription.text = menuItem.description
        cell.menuItemPrice.text = menuItem.price.asPriceString

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let menuItemVC = segue.destination as! MenuItemViewController
        menuItemVC.menuItem = menuItemsForCategory[tableView.indexPathForSelectedRow!.row]
    }
}
