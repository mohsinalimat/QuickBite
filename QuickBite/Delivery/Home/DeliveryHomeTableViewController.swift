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
import Alamofire
import CoreLocation
import Hero

class DeliveryHomeTableViewController: UITableViewController {
    private var tdNavController: TDNavigationController?
    
    private var highlightedCategories: [HighlightedRestaurantCategory] = []
    private var allRestaurants: [Restaurant] = []
    private let homeHeader = DeliveryHomeHeader()
    private let homeHeaderHeight: CGFloat = 65
    private var loadingCoverView: LoadingCoverView!
    
    private var navBarTapRecognizer: UITapGestureRecognizer!
    
    private var selectedAddress: Address!

    private var selectedRestaurant: Restaurant!
    private var sortByTime = true
    
    // Fix edge case where backing out of searchVC and then immediately
    // tapping the search bar again would corrupt the navigation bar
    private var searchIsInCooldown = false
    
    enum TableViewSection: Int {
        case search
        case highlightedRestaurantCategories
        case allRestaurants
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerWasTapped))
        
        // Cover tableview with loading view
        loadingCoverView = LoadingCoverView(loadingText: "Finding restaurants near you...")
        loadingCoverView.cover(parentView: self.navigationController!.view!)
        
        // Download restaurants from Firestore
        let db = Firestore.firestore()
        db.collection("restaurants").getDocuments() { (querySnapshot, err) in
            if let err = err {
                DDLogError("Error getting documents: \(err)")
            } else {
                self.setupRestaurants(querySnapshot!.documents)
            }
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset.top = 10
        
        tdNavController = self.navigationController as? TDNavigationController
        selectedAddress = UserUtil.currentUser!.selectedAddress
        addHomeHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.addGestureRecognizer(navBarTapRecognizer)
        
        // Check if selected address has changed
        let address = UserUtil.currentUser!.selectedAddress
        if address.id != selectedAddress.id {
            // Refresh screen
            selectedAddress = address
            loadingCoverView.cover(parentView: self.navigationController!.view!)
            homeHeader.setStreetLabel(selectedAddress.displayName)
            setupRestaurants()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.searchIsInCooldown = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.removeGestureRecognizer(navBarTapRecognizer)
        searchIsInCooldown = true
    }
    
    // MARK: - Home Header
    private func addHomeHeader() {
        homeHeader.setStreetLabel(selectedAddress.displayName)
        
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
    
    @objc private func headerWasTapped() {
        let accountStoryboard = UIStoryboard(name: "Account", bundle: nil)
        let addressesVC = accountStoryboard.instantiateViewController(withIdentifier: "AddressesVC")
        
        presentInSeparateNavController(addressesVC, animated: true)
    }
    
    // MARK: - Restaurants Data
    private func setupRestaurants(_ documents: [QueryDocumentSnapshot] = []) {
        if !documents.isEmpty {
            allRestaurants = documents.compactMap({ Restaurant(dictionary: $0.data()) })
        }
        
        DistanceTimeUtil.getDistanceTimes(allRestaurants, forAddress: selectedAddress) { result, error in
            self.sortRestaurantsByTime(result)
            self.populateHighlightedCategories()
            self.tableView.reloadData()
            self.loadingCoverView.hide()
        }
    }
    
    private func sortRestaurantsByTime(_ distanceTimes: [String : DistanceTime]?) {
        allRestaurants.forEach { restaurant in
            if let restaurantDt = distanceTimes?[restaurant.id], restaurantDt.status == "OK" {
                restaurant.distanceTime = restaurantDt
            } else {
                // Google matrix API failed to find distance time.
                // Calculate distance manually and create rough time estimate
                // based off that
                manuallyCalculateDistanceTime(restaurant)
            }
        }
        
        // In the event that the Google distance matrix API completely fails,
        // sort the restaurants by distance rather than time. Also set a variable
        // so that the tableView and collectionViews know to display distance instead of time.
        if let _ = distanceTimes {
            allRestaurants.sort(by: { $0.distanceTime!.timeValue < $1.distanceTime!.timeValue } )
        } else {
            allRestaurants.sort(by: { $0.distanceTime!.distanceValue < $1.distanceTime!.distanceValue } )
            sortByTime = false
        }
    }
    
    private func manuallyCalculateDistanceTime(_ restaurant: Restaurant) {
        let restaurantLoc = CLLocation(latitude: restaurant.latitude,
                                       longitude: restaurant.longitude)
        
        let addressLoc = CLLocation(latitude: UserUtil.currentUser!.selectedAddress.latitude,
                                    longitude: UserUtil.currentUser!.selectedAddress.longitude)
        
        let distance = ((restaurantLoc.distance(from: addressLoc) / 1000) * 100).rounded() / 100
        let timeEstimate = estimateTimeFromDistance(distance)
        
        restaurant.distanceTime = DistanceTime(status: "MANUAL",
                                               distance: "\(distance)km",
                                               distanceValue: Int(distance * 1000),
                                               time: "\(timeEstimate) mins",
                                               timeValue: timeEstimate * 60)
    }
    
    // Estimates a travel time for a beeline distance
    private func estimateTimeFromDistance(_ distance: Double) -> Int {
        let timeEstimate = Int(distance * 10)
        if timeEstimate > 45 {
            return 45
        } else {
            return timeEstimate
        }
    }
    
    // MARK: - Highlighted Categories
    private func populateHighlightedCategories() {
        let topPickRestos = allRestaurants.filter({ $0.topPick })
        highlightedCategories = [HighlightedRestaurantCategory(categoryName: "Top Picks in Cagayan",
                                                               restaurants: topPickRestos)]
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
        let tableViewSection = TableViewSection(rawValue: indexPath.section)!
        switch tableViewSection {
        case .search:
            return tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        case .highlightedRestaurantCategories:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HighlightedRestaurantCategoryCell", for: indexPath) as! HighlightedRestaurantCategoryTableViewCell
            
            cell.categoryName.text = highlightedCategories[indexPath.row].categoryName
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            cell.peekImplementation.delegate = self
            
            return cell
        case .allRestaurants:
            if indexPath.row == 0 { // Header cell
                let header = tableView.dequeueReusableCell(withIdentifier: "AllRestaurantsHeaderCell")
                return header!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AllRestaurantsCell", for: indexPath) as! AllRestaurantsTableViewCell
                
                let restaurant = allRestaurants[indexPath.row - 1]
                cell.restaurantName.text = restaurant.name
                cell.restaurantCategories.text = restaurant.categories
                cell.restaurantImage.sd_setImage(with: URL(string: restaurant.imageURL))
                cell.restaurantRating.text = String(restaurant.rating)
                if sortByTime {
                    cell.deliveryTimeEstimate.text = restaurant.distanceTime!.time
                } else {
                    cell.deliveryTimeEstimate.text = restaurant.distanceTime!.distance
                }
                
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableViewSection = TableViewSection(rawValue: indexPath.section) else {
            return
        }
        
        if tableViewSection == .search {
            guard !searchIsInCooldown else { return }
            
            navigationController?.hero.isEnabled = true
            navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .fade)
            performSegue(withIdentifier: "ShowSearchSegue", sender: nil)
        } else if tableViewSection == .allRestaurants {
            selectedRestaurant = allRestaurants[indexPath.row - 1] // Account for header cell
            showRestaurant()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tdNavController?.showShadow(-tableView.contentOffset.y < (homeHeaderHeight - 70))
    }
    
    private func showRestaurant() {
        performSegue(withIdentifier: "ShowRestaurantSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let restaurantVC = segue.destination as? RestaurantViewController {
            restaurantVC.restaurant = selectedRestaurant
        } else if let searchVC = segue.destination as? SearchViewController {
            searchVC.restaurants = allRestaurants
            if let searchCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HomeSearchBarTableViewCell, let searchPrompt = searchCell.searchPrompt.text {
                searchVC.searchPrompt = searchPrompt
            }
        }
    }
}

// MARK: - Highlighed Restaurant Cells
extension DeliveryHomeTableViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return highlightedCategories[collectionView.tag].restaurants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HighlightedRestaurantCell", for: indexPath) as! HighlightedRestaurantCollectionViewCell
        
        let restaurant = highlightedCategories[collectionView.tag].restaurants[indexPath.row]
        
        cell.restaurantName.text = restaurant.name
        cell.imageView.sd_setImage(with: URL(string: restaurant.imageURL))
        if sortByTime {
            cell.timeAndDeliveryFee.text = restaurant.distanceTime!.time + " · Free delivery"
        } else {
            cell.timeAndDeliveryFee.text = restaurant.distanceTime!.distance + " · Free delivery"
        }
        
        return cell
    }
    
}

extension DeliveryHomeTableViewController: MSPeekImplementationDelegate {
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRestaurant = highlightedCategories[collectionView.tag].restaurants[indexPath.row]
        showRestaurant()
    }
}

class AllRestaurantsTableViewCell: UITableViewCell {
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantCategories: UILabel!
    @IBOutlet weak var restaurantRating: UILabel!
    @IBOutlet weak var deliveryTimeEstimate: UILabel!
}
