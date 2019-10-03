//
//  RestaurantViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/26/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var deliveryTime: UILabel!
    @IBOutlet weak var restaurantCategories: UILabel!
    @IBOutlet weak var distanceAndAddress: UILabel!
    
    @IBOutlet weak var featuredItemsContainerView: UIView!
    @IBOutlet weak var featuredItemsCollectionView: UICollectionView!
    @IBOutlet weak var menuCategoriesTableView: UITableView!
    
    var restaurant: Restaurant!
    
    private var featuredItems: [MenuItem]!
    private var menuCategories: [String]!
    
    private var selectedMenuItem: MenuItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featuredItemsCollectionView.register(UINib(nibName: "FeaturedItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeaturedItemCell")
        
        restaurantName.text = restaurant.name
        restaurantCategories.text = restaurant.categories
        deliveryTime.text = restaurant.distanceTime!.time.chompAt(" ")
        distanceAndAddress.text = restaurant.distanceTime!.distance + " · " + restaurant.address.chompAt(", Cag")
        
        menuCategories = restaurant.getMenuCategories()
        featuredItems = restaurant.getFeaturedItems()
        if featuredItems.isEmpty {
            featuredItemsContainerView.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // In case the user opened the cart from this screen or any of it's sub-screens,
        // clear the redirect here so that the main screen doesn't hop back here.
        UserDefaults.standard.removeObject(forKey: UDKeys.redirectToCartRestaurant)
        
        if let selectionIndexPath = menuCategoriesTableView.indexPathForSelectedRow {
            menuCategoriesTableView.deselectRow(at: selectionIndexPath, animated: false)
        }
    }
    
    // Featured Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedItemCell", for: indexPath) as! FeaturedItemCollectionViewCell
        
        let featuredItem = featuredItems[indexPath.row]
        cell.title.text = featuredItem.itemName
        cell.price.text = featuredItem.price.asPriceString
        cell.imageView.sd_setImage(with: URL(string: featuredItem.imageUrl))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMenuItem = featuredItems[indexPath.row]
        performSegue(withIdentifier: "ShowMenuItemSegue", sender: nil)
    }
}

// Menu Categories tableview
extension RestaurantViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCategoryCell", for: indexPath)
        cell.textLabel?.text = menuCategories[indexPath.row]
        cell.detailTextLabel?.text = String(restaurant.getItemsInCategory(menuCategories[indexPath.row]).count)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuTableVC = segue.destination as? MenuCategoryViewController {
            let category = menuCategories[menuCategoriesTableView.indexPathForSelectedRow!.row]
            menuTableVC.restaurant = restaurant
            menuTableVC.menuCategory = category
        } else if let menuItemVC = segue.destination as? MenuItemViewController {
            menuItemVC.menuItem = selectedMenuItem
            menuItemVC.restaurant = restaurant
            if let tdTabBarController = self.navigationController?.tabBarController as? TDTabBarController {
                menuItemVC.delegate = tdTabBarController
            }
        }
    }
}
