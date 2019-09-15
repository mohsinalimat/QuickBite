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
    
    @IBOutlet weak var featuredItemsCollectionView: UICollectionView!
    @IBOutlet weak var menuCategoriesTableView: UITableView!
    
    var restaurant: Restaurant!
    
    let featuredItems = [["5pc. Barbeque Chicken Wings", "₱139"], ["Chicken Inasal", "₱110"], ["Strawberry Smoothie", "₱99"]]
    let featuredItemsPhotos = [UIImage(named: "sample_food_3"), UIImage(named: "food_sample_inasal"), UIImage(named: "smoothie")]
    
    let menuCategories = ["Popular Items", "Chicken", "Pork", "Salads", "Sides", "Beverages"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featuredItemsCollectionView.register(UINib(nibName: "FeaturedItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeaturedItemCell")
        
        restaurantName.text = restaurant.name
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        cell.title.text = featuredItems[indexPath.row][0]
        cell.price.text = featuredItems[indexPath.row][1]
        cell.imageView.image = featuredItemsPhotos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        cell.detailTextLabel?.text = "\(Int.random(in: 1...20))"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MenuTableViewController {
            destinationVC.title = menuCategories[menuCategoriesTableView.indexPathForSelectedRow!.row]
        } else if let destinationVC = segue.destination as? MenuItemViewController {
            // Pass menu item object to destinationVC here
        }
        
    }
}
