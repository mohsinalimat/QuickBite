//
//  SearchViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 10/1/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import CocoaLumberjack

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var trySearchingLabel: UILabel!
    @IBOutlet weak var searchPromptLabel: UILabel!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var searchPrompt: String?
    var restaurants: [Restaurant]!
    private var filteredRestaurants = [Restaurant]()
    
    private var tdTabBarController: TDTabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithTransparentBackground()
            navBarAppearance.backgroundColor = .clear

            navigationController?.navigationBar.isTranslucent = true
            navigationController?.navigationBar.standardAppearance = navBarAppearance
        } else {
            // For some reason creating a UIImage from .tertiarySystemGroupedBackgroundCompat
            // was not working and the navBar would remain white.
            navigationController?.navigationBar.setBackgroundImage(UIImage(named: "tertiary_system_grouped_background"), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        
        searchResultsTableView.rowHeight = UITableView.automaticDimension
        searchResultsTableView.estimatedRowHeight = 60
        
        searchPromptLabel.text = searchPrompt
        
        tdTabBarController = self.tabBarController as? TDTabBarController
        
        searchTextField.addTarget(self, action: #selector(searchTextDidChange), for: UIControl.Event.editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hero.isEnabled = true
        
        if let selectedIndexPath = searchResultsTableView.indexPathForSelectedRow {
            searchResultsTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
        tdTabBarController?.showCartBanner(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *) {
            searchTextField.becomeFirstResponder()
        } else {
            // Fix a bug in iOS 10 where the searchTextField would become the first responder
            // but neither the caret nor any entered text would be visible.
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                self.searchTextField.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hero.isEnabled = false
        searchTextField.resignFirstResponder()
        
        // Reset nav bar
        let tdNavBar = navigationController as! TDNavigationController
        tdNavBar.configureNavBarAppearance()
        
        tdTabBarController?.showCartBanner(animated: false)
    }
    
    @objc func searchTextDidChange() {
        trySearchingLabel.alpha = searchTextField.text!.isEmpty ? 1 : 0
        searchPromptLabel.alpha = searchTextField.text!.isEmpty ? 1 : 0
        updateSearchResults()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func updateSearchResults() {
        let searchText = searchTextField.text!.lowercased()
        
        filteredRestaurants = restaurants.filter({ (restaurant) -> Bool in
            return restaurant.name.lowercased().contains(searchText) ||
                restaurant.categories.lowercased().contains(searchText)
        })
        
        searchResultsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantSearchResultCell", for: indexPath) as! SearchResultTableViewCell
        
        let restaurant = filteredRestaurants[indexPath.row]
        cell.restaurantName.text = restaurant.name
        cell.restaurantCategories.text = restaurant.categories
        cell.deliveryEstimate.text = restaurant.deliveryTimeEstimate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.hero.isEnabled = false
        performSegue(withIdentifier: "ShowRestaurantFromSearchSegue", sender: nil)
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let restaurantVC = segue.destination as? RestaurantViewController {
            restaurantVC.restaurant = filteredRestaurants[searchResultsTableView.indexPathForSelectedRow!.row]
        }
    }

}

class SearchResultTableViewCell: UITableViewCell {
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantCategories: UILabel!
    @IBOutlet weak var deliveryEstimate: UILabel!
}
