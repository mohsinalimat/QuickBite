//
//  AddNewAddressSearchViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import FirebaseAuth
import GooglePlaces

class AddNewAddressSearchViewController: UIViewController {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    @IBOutlet weak var searchBarContainer: UIView!
    
    private var selectedPlace: GMSPlace?
    
    private var placeWasSelected = false // Used to detect if the user hit the back button
    
    var firstTimeSetupMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        // Fix layout bug where search results appear ~70px below search bar
        if #available(iOS 11.0, *) {
            resultsViewController?.automaticallyAdjustsScrollViewInsets = false
            let bottomOfSearchBar = searchBarContainer.frame.origin.y + searchBarContainer.frame.height
            resultsViewController?.additionalSafeAreaInsets.top = bottomOfSearchBar
        }
        
        // Dark Mode
        if #available(iOS 13.0, *) {
            resultsViewController?.tableCellBackgroundColor = .secondarySystemBackground
            resultsViewController?.primaryTextColor = .secondaryLabel
            resultsViewController?.primaryTextHighlightColor = .label
            resultsViewController?.secondaryTextColor = .secondaryLabel
        }
        
        resultsViewController?.delegate = self
        resultsViewController?.autocompleteBoundsMode = .restrict
        let leftCoordinate = CLLocationCoordinate2D(latitude: 8.504086, longitude: 124.615774)
        let rightCoordinate = CLLocationCoordinate2D(latitude: 8.422772, longitude: 124.657019)
        let coordinateBounds = GMSCoordinateBounds(coordinate: leftCoordinate, coordinate: rightCoordinate)
        resultsViewController?.autocompleteBounds = coordinateBounds
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        styleSearchBar()
        
        searchBarContainer.addSubview((searchController?.searchBar)!)
        view.addSubview(searchBarContainer)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // This makes the view area include the nav bar even though it is opaque.
        // Adjust the view placement down.
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .top
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController?.isActive = true
        // For some reason becomeFirstResponder() needs to be called in the main queue explicitly
        DispatchQueue.main.async {
            self.searchController?.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // In first time setup, we want to clear the currentUser and sign out of FB
        // if the user navigates back to the GetStartedVC
        guard firstTimeSetupMode else {
            return
        }
        
        if placeWasSelected == false {
            // User is going backwards to GetStartedViewController
            // Log out user if there is a user logged in
            try? Auth.auth().signOut()
            UserUtil.clearCurrentUser()
        }
    }
    
    private func styleSearchBar() {
        let searchBar = searchController?.searchBar
        searchBar?.placeholder = "Add a delivery address..."
        searchBar?.searchBarStyle = .minimal
        searchBar?.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar?.setBackgroundImage(UIImage(color: .systemBackgroundCompat), for: .any, barMetrics: .default)
        searchBar?.setShowsCancelButton(false, animated: false)
        
        if #available(iOS 13, *) {
            searchBar?.searchTextField.font = .systemFont(ofSize: 24, weight: .medium)
        } else if let textField = searchBar?.value(forKey: "searchField") as? UITextField {
            textField.font = .systemFont(ofSize: 24, weight: .medium)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addNewAddressMapVC = segue.destination as? AddNewAddressMapViewController {
            addNewAddressMapVC.selectedAddress = selectedPlace
            addNewAddressMapVC.firstTimeSetupMode = firstTimeSetupMode
        }
    }
}

// Handle the user's selection.
extension AddNewAddressSearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        selectedPlace = place
        placeWasSelected = true
        performSegue(withIdentifier: "ShowAddressMapSegue", sender: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
