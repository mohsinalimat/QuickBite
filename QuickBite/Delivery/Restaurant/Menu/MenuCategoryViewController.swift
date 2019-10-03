//
//  MenuCategoryViewController2.swift
//  QuickBite
//
//  Created by Griffin Smalley on 10/3/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class MenuCategoryViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var largeTitle: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    
    var restaurant: Restaurant!
    var menuCategory: String!
    
    private var menuItemsForCategory: [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.rowHeight = UITableView.automaticDimension
        categoryTableView.estimatedRowHeight = 44
        
        largeTitle.text = menuCategory
        
        menuItemsForCategory = restaurant.getItemsInCategory(menuCategory)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsForCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemTableViewCell

        let menuItem = menuItemsForCategory[indexPath.row]
        if menuItem.imageUrl.isNotEmpty {
            cell.menuItemImage.sd_setImage(with: URL(string: menuItem.imageUrl))
        } else {
            cell.imageHeightConstraint.constant = 0
        }
        cell.menuItemName.text = menuItem.itemName
        cell.menuItemDescription.text = menuItem.description
        cell.menuItemPrice.text = menuItem.price.asPriceString

        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let menuItemVC = segue.destination as! MenuItemViewController
        menuItemVC.menuItem = menuItemsForCategory[categoryTableView.indexPathForSelectedRow!.row]
        menuItemVC.restaurant = restaurant
        if let tdTabBarController = self.navigationController?.tabBarController as? TDTabBarController {
            menuItemVC.delegate = tdTabBarController
        }
    }
}

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet weak var menuItemImage: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuItemName: UILabel!
    @IBOutlet weak var menuItemDescription: UILabel!
    @IBOutlet weak var menuItemPrice: UILabel!
}
