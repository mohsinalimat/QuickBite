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
    
    private var highlightedCategories: [HighlightedRestaurantCategory] = []
    private var allRestos: [Restaurant] = []
    private let homeHeader = DeliveryHomeHeader()
    private let homeHeaderHeight: CGFloat = 65
    private var loadingCoverView: LoadingCoverView!
    
    private var selectedRestaurant: Restaurant!
    
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

//        let restaurantRef = db.collection("restaurants")
//
//        restaurantRef.document("chika_loca").setData([
//            "name": "Chika Loca!",
//            "categories": "Chicken, BBQ",
//            "open_hours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
//            "rating": 3.5,
//            "image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/food_sample_inasal.jpg?alt=media&token=70e75f54-b368-4c44-a4b7-5bda1caf5c53",
//            "address": "",
//            "top_pick": true,
//            "menu_items": [
//                [
//                    "item_name": "5pc. BBQ Chicken Wings",
//                    "description": "",
//                    "category": "Chicken",
//                    "featured": true,
//                    "item_image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/sample_food_3.jpg?alt=media&token=2eb2b213-df11-45cf-8867-66785d9f8075",
//                    "price": 110,
//                    "item_option_categories": [
//                        [
//                            "options_category_name": "Sides",
//                            "required": true,
//                            "single_selection": true,
//                            "options": [
//                                [
//                                    "option_name": "Side1",
//                                    "added_price": 30
//                                ],
//                                [
//                                    "option_name": "Side2",
//                                    "added_price": 40
//                                ]
//                            ]
//                        ],
//                        [
//                            "options_category_name": "Extras",
//                            "required": false,
//                            "single_selection": false,
//                            "options": [
//                                [
//                                    "option_name": "Extra BBQ Sauce",
//                                    "added_price": 25
//                                ],
//                                [
//                                    "option_name": "Extra Garlic Sauce",
//                                    "added_price": 20
//                                ],
//                                [
//                                    "option_name": "Extra Magic Sauce",
//                                    "added_price": 100
//                                ],
//                                [
//                                    "option_name": "Extra Super Magic Sauce Long Title",
//                                    "added_price": 150
//                                ]
//                            ]
//                        ]
//                    ]
//                ],
//                [
//                    "item_name": "Strawberry Smoothie",
//                    "description": "",
//                    "category": "Drinks",
//                    "featured": false,
//                    "item_image_url": "",
//                    "price": 99,
//                    "item_option_categories": []
//                ],
//                [
//                    "item_name": "Chicken Inasal",
//                    "description": "",
//                    "category": "Chicken",
//                    "featured": true,
//                    "item_image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/inasal_2.png?alt=media&token=b789002b-96ff-47d2-8e43-defb8dff3c76",
//                    "price": 115,
//                    "item_option_categories": []
//                ]
//            ]
//            ])
//
//        restaurantRef.document("house_of_pancakes").setData([
//            "name": "House of Pancakes",
//            "categories": "Breakfast, Smoothies",
//            "open_hours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
//            "rating": 4.7,
//            "image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/Egg-free-french-toast_post.jpg?alt=media&token=8de1aa40-946c-4006-8cd6-6bc462e4236c",
//            "address": "",
//            "top_pick": false,
//            "menu_items": [
//                [
//                    "item_name": "Brioche French Toast",
//                    "description": "",
//                    "category": "Breakfast",
//                    "featured": true,
//                    "price": 135,
//                    "item_option_categories": [
//                        [
//                            "options_category_name": "Sides",
//                            "required": true,
//                            "single_selection": true,
//                            "options": [
//                                [
//                                    "option_name": "Blueberries",
//                                    "added_price": 0
//                                ],
//                                [
//                                    "option_name": "Strawberries",
//                                    "added_price": 0
//                                ]
//                            ]
//                        ],
//                        [
//                            "options_category_name": "Extras",
//                            "required": false,
//                            "single_selection": false,
//                            "options": [
//                                [
//                                    "option_name": "Extra butter packets",
//                                    "added_price": 25
//                                ],
//                                [
//                                    "option_name": "Extra syrup",
//                                    "added_price": 20
//                                ]
//                            ]
//                        ]
//                    ]
//                ],
//                [
//                    "item_name": "Banana Smoothie",
//                    "description": "",
//                    "category": "Drinks",
//                    "featured": false,
//                    "price": 99,
//                    "item_option_categories": []
//                ]
//            ]
//            ])

        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset.top = 10
        
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
        loadingCoverView.hide()
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
        homeHeader.showShadow(-tableView.contentOffset.y < (homeHeaderHeight - 70))
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
