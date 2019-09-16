//
//  DeliveryHomeTableViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/31/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class DeliveryHomeTableViewController: UITableViewController {
    
    private var highlightedCategories: [HighlightedRestaurantCategory] = []
    private var allRestos: [Restaurant] = []
    private let homeHeader = DeliveryHomeHeader()
    
    private let homeHeaderHeight: CGFloat = 65
    
    private var selectedRestaurant: Restaurant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        db.collection("restaurants").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.loadRestaurants(querySnapshot!.documents)
            }
        }

        // Fake Data
//        let resto1 = Restaurant(name: "Chika Loca!", image: UIImage(imageLiteralResourceName: "food_sample_inasal"))
//        let resto2 = Restaurant(name: "Chicken Rotizado", image: UIImage(imageLiteralResourceName: "rotizado"))
//        let resto3 = Restaurant(name: "House of Pancakes", image: UIImage(imageLiteralResourceName: "pancakes"))
//        let resto4 = Restaurant(name: "Little Italy Pizzaria - SuperMall Downtown - 5th floor", image: UIImage(imageLiteralResourceName: "sample_food_2"))
//        let resto5 = Restaurant(name: "Burger King", image: UIImage(imageLiteralResourceName: "sample_food_1"))
//        let resto6 = Restaurant(name: "Hot Chix", image: UIImage(imageLiteralResourceName: "sample_food_3"))
        
//        let highlightedCategory1 = HighlightedRestaurantCategory(categoryName: "Top Picks in Cagayan",
//                                                      restaurants: [resto4, resto2, resto1, resto3])
//        let highlightedCategory2 = HighlightedRestaurantCategory(categoryName: "Burgers & Wings",
//                                                                restaurants: [resto1, resto5, resto1, resto6])
        
//        highlightedCategories = [highlightedCategory1, highlightedCategory2]
        
//        allRestos = [resto1, resto2, resto3, resto4, resto5, resto6]
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let navBar = self.navigationController!.navigationBar
        navBar.addSubview(homeHeader)
        
        homeHeader.setStreetLabel(AddressBook.getDefaultAddress().street)
        
        homeHeader.translatesAutoresizingMaskIntoConstraints = false
        homeHeader.leftAnchor.constraint(equalTo: navBar.leftAnchor).isActive = true
        homeHeader.rightAnchor.constraint(equalTo: navBar.rightAnchor).isActive = true
        homeHeader.heightAnchor.constraint(equalToConstant: homeHeaderHeight).isActive = true
        homeHeader.topAnchor.constraint(equalTo: navBar.topAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeHeader.show(true)
    }
    
    
    private func loadRestaurants(_ documents: Array<QueryDocumentSnapshot>) {
        for document in documents {
            if let restaurant = Restaurant(dictionary: document.data()) {
                allRestos.append(restaurant)
            } else {
                print("couldn't append restaurant! \(document.data())")
            }
        }
        populateHighlightedCategories()
        tableView.reloadData()
    }
    
    private func populateHighlightedCategories() {
        var topPickRestos: [Restaurant] = []
        for resto in allRestos {
            if resto.topPick {
                topPickRestos.append(resto)
            }
        }
        highlightedCategories.append(HighlightedRestaurantCategory(categoryName: "Top Picks in Cagayan",
                                                                   restaurants: topPickRestos))
    }
    
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Section 1: Search bar
        // Section 2: Highlighted Restaurant categories ("Top Picks", "Breakfast", etc...)
        // Section 3: All Restaurants
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Search
            return 1
        case 1: // Highlighted Restaurant categories
            return highlightedCategories.count
        case 2: // All Restaurants
            return allRestos.count + 1 // + 1 for the header cell
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Search
            return tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        case 1: // Highlighted Restaurant categories
            let cell = tableView.dequeueReusableCell(withIdentifier: "HighlightedRestaurantCategoryCell", for: indexPath) as! HighlightedRestaurantCategoryTableViewCell
            
            cell.categoryName.text = highlightedCategories[indexPath.row].categoryName
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            cell.peekImplementation.delegate = self
            
            return cell
        case 2: // All Restaurants
            if indexPath.row == 0 { // Header cell
                let header = tableView.dequeueReusableCell(withIdentifier: "AllRestaurantsHeaderCell")
                return header!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AllRestaurantsCell", for: indexPath) as! AllRestaurantsTableViewCell
                
                let restaurant = allRestos[indexPath.row - 1]
                cell.restaurantName.text = restaurant.name
                cell.restaurantCategories.text = restaurant.categories
                cell.restaurantImage.sd_setImage(with: URL(string: restaurant.imageURL), placeholderImage: UIImage(named: "delivery"))
                cell.restaurantRating.text = String(restaurant.rating)
                
                return cell
            }
        default:
            fatalError()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        homeHeader.showShadow(shouldShowHeaderShadow)
    }
    
    private var shouldShowHeaderShadow: Bool {
        return -tableView.contentOffset.y < (homeHeaderHeight - 70)
    }
}

// Highlighed Restaurant Cells
extension DeliveryHomeTableViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return highlightedCategories[collectionView.tag].restaurants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HighlightedRestaurantCell", for: indexPath) as! HighlightedRestaurantCollectionViewCell
        
        let restaurant = highlightedCategories[collectionView.tag].restaurants[indexPath.row]
        
        cell.restaurantName.text = restaurant.name
        cell.imageView.sd_setImage(with: URL(string: restaurant.imageURL), placeholderImage: UIImage(named: "delivery"))
        
        return cell
    }
    
}

extension DeliveryHomeTableViewController: MSPeekImplementationDelegate {
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRestaurant = highlightedCategories[collectionView.tag].restaurants[indexPath.row]
        homeHeader.show(false)
        performSegue(withIdentifier: "ShowRestaurantSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? RestaurantViewController {
            destinationVC.restaurant = selectedRestaurant
        }
    }
}
