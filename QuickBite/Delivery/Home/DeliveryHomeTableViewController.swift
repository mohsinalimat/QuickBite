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
import CocoaLumberjack

class DeliveryHomeTableViewController: UITableViewController {
    private var tdNavController: TDNavigationController?
    
    private var highlightedCategories: [HighlightedRestaurantCategory] = []
    private var allRestaurants: [Restaurant] = []
    private let homeHeader = DeliveryHomeHeader()
    private let homeHeaderHeight: CGFloat = 65
    private var loadingCoverView: LoadingCoverView!
    
    private var selectedRestaurant: Restaurant!
    
    enum TableViewSection: Int {
        case search
        case highlightedRestaurantCategories
        case allRestaurants
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cover tableview with loading view
        loadingCoverView = LoadingCoverView(loadingText: "Finding restaurants near you...")
        loadingCoverView.cover(parentView: self.navigationController!.view!)
        
        // Download restaurants from Firestore
        let db = Firestore.firestore()
        db.collection("restaurants").getDocuments() { (querySnapshot, err) in
            if let err = err {
                DDLogError("Error getting documents: \(err)")
            } else {
                self.loadRestaurants(querySnapshot!.documents)
            }
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset.top = 10
        
        tdNavController = self.navigationController as? TDNavigationController
        
        homeHeader.setStreetLabel(UserUtil.currentUser!.defaultAddress.street)
        addHomeHeader()
        
    }
    
    private func addHomeHeader() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 44))

        homeHeader.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(homeHeader)
        
        NSLayoutConstraint.activate([
            homeHeader.topAnchor.constraint(equalTo: container.topAnchor),
            homeHeader.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            homeHeader.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            homeHeader.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])

        self.navigationItem.titleView = container
    }
    
    private func loadRestaurants(_ documents: Array<QueryDocumentSnapshot>) {
        for document in documents {
            if let restaurant = Restaurant(dictionary: document.data()) {
                allRestaurants.append(restaurant)
            } else {
                print("couldn't append restaurant! \(document.data())")
            }
        }
        populateHighlightedCategories()
        tableView.reloadData()
        loadingCoverView.hide()
    }
    
    private func populateHighlightedCategories() {
        var topPickRestos: [Restaurant] = []
        for resto in allRestaurants {
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
        guard let tableViewSection = TableViewSection(rawValue: section) else { return 0 }
        switch tableViewSection {
        case .search:
            return 1
        case .highlightedRestaurantCategories:
            return highlightedCategories.count
        case .allRestaurants:
            return allRestaurants.count + 1 // + 1 for the header cell
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
                
                let restaurant = allRestaurants[indexPath.row - 1]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableViewSection = TableViewSection(rawValue: indexPath.section), tableViewSection == .allRestaurants else {
            return
        }
        selectedRestaurant = allRestaurants[indexPath.row]
        showRestaurant()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tdNavController?.showShadow(-tableView.contentOffset.y < (homeHeaderHeight - 70))
    }
    
    private func showRestaurant() {
        performSegue(withIdentifier: "ShowRestaurantSegue", sender: nil)
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
        showRestaurant()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? RestaurantViewController {
            destinationVC.restaurant = selectedRestaurant
        }
    }
}
