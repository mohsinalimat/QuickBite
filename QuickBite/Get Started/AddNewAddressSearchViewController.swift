//
//  AddNewAddressSearchViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import GooglePlaces

class AddNewAddressSearchViewController: UIViewController {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
//    var resultView: UITextView?
    @IBOutlet weak var searchBarContainer: UIView!
    
    private var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        // Fix layout bug where search results appear ~70px below search bar
        if #available(iOS 11.0, *) {
            resultsViewController?.automaticallyAdjustsScrollViewInsets = false
            resultsViewController?.additionalSafeAreaInsets.top = searchBarContainer.frame.height - 5
        }
        resultsViewController?.delegate = self
        resultsViewController?.autocompleteBoundsMode = .restrict
        let leftCoordinate = CLLocationCoordinate2D(latitude: 8.504086, longitude: 124.615774)
        let rightCoordinate = CLLocationCoordinate2D(latitude: 8.422772, longitude: 124.657019)
        let coordinateBounds = GMSCoordinateBounds(coordinate: leftCoordinate, coordinate: rightCoordinate)
        resultsViewController?.autocompleteBounds = coordinateBounds
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        let searchBar = searchController?.searchBar
        searchBar?.placeholder = "Add a delivery address..."
        searchBar?.searchBarStyle = .minimal
        searchBar?.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar?.setBackgroundImage(UIImage(color: .systemBackgroundCompat), for: .any, barMetrics: .default)
        searchBar?.setShowsCancelButton(false, animated: false)
        if let textField = searchBar?.value(forKey: "searchField") as? UITextField {
            textField.font = .systemFont(ofSize: 24, weight: .medium)
            if #available(iOS 13, *) {
                searchController?.searchBar.searchTextField.textColor = .tertiaryLabel
                searchBar?.searchTextField.textColor = .systemRed
                searchBar?.searchTextField.tintColor = .systemRed
            } else {
                textField.textColor = .tertiaryLabelCompat
            }
        }
        
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
        // For some reason becomeFirstResponder() needs to be called explicitly in the main queue
        DispatchQueue.main.async {
            self.searchController?.searchBar.becomeFirstResponder()
        }
    }
    
    private func moveForward() {
        performSegue(withIdentifier: "ShowAddressMapSegue", sender: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if let addNewAddressMapVC = segue.destination as? AddNewAddressMapViewController {
           addNewAddressMapVC.address = selectedPlace
       }
    }
}

// Handle the user's selection.
extension AddNewAddressSearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
//        searchController?.isActive = false
        // Do something with the selected place.
        selectedPlace = place
        performSegue(withIdentifier: "ShowAddressMapSegue", sender: nil)
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
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
