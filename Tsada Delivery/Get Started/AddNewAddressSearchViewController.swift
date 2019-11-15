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
    var searchController: CustomSearchController?
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
        
        searchController = CustomSearchController(searchResultsController: resultsViewController)
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
        searchBar?.setBackgroundImage(UIImage(color: .systemBackgroundCompat), for: .any, barMetrics: .default)
        
        searchBar?.tintColor = #colorLiteral(red: 0.9361338615, green: 0.3251743913, blue: 0.3114004433, alpha: 1) // Icon is not tinted in iOS 13
        /// UISearchBar behaves completely differently in iOS 13 and pre-iOS 13 devices. Please read carefully before trying to modify!
        /// textFieldBackground color:
        ///      pre-13 - Extract textField using .value(forKey: "searchField"), then use textField.backgroundcolor property.
        ///         13 - .setSearchFieldBackgroundImage(blank UIImage)
        /// textFieldFont:
        ///      pre-13 - Extract textField using .value(forKey: "searchField"), then use textField.font property.
        ///         13 - Use .searchTextField (available only in iOS 13) property and set its font
        /// Hide Cancel Button:
        ///      pre-13 - There is an iOS bug that causes iOS 12 and lower devices to ignore the built-in .setShowsCancelButton.
        ///            The workaround is to use a custom subclass of UISearchBar, which in turn can only be utilized with a custom
        ///            subclass of UISearchController 🙄.
        ///         13 - For some fucking reason, iOS 13 ignores the custom subclass's overriden .setShowsCancelButton 😡. So we have to
        ///            call .setShowsCancelButton regardless.
        /// Custom Search Icon Image:
        ///      Calling .setImage works for both i0S 13 and pre-iOS 13. However, it is seemingly not resizable on iOS 13 and will render as
        ///      whatever dimensions the image file is. On pre-iOS, the image will be extremely tiny by default, regardless of the dimensions
        ///      of the image file itself AND regardless of the file type (.png or .pdf produce same result)
        ///      pre-13 - Resize the image by extracting it from the textField's leftView property, then set it's frame size.
        searchBar?.setImage(UIImage(named: "map_marker-25"), for: .search, state: .normal)
        if #available(iOS 13, *) {
            searchBar?.setSearchFieldBackgroundImage(UIImage(), for: .normal)
            searchBar?.setShowsCancelButton(false, animated: false) // Custom class gets ignored otherwise 😡
            searchBar?.searchTextField.font = .systemFont(ofSize: 24, weight: .medium)
        } else if let textField = searchBar?.value(forKey: "searchField") as? UITextField {
            if let textFieldImage = textField.leftView as? UIImageView {
                textFieldImage.frame.size = CGSize(width: 25, height: 25)
            }
            textField.backgroundColor = .white
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

// These custom subclasses fix a bug where setShowsCancelButton would be ignored on pre-iOS 13 devices
// TODO: Move all searchbar styling to this class?
class CustomSearchBar: UISearchBar {
    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        super.setShowsCancelButton(false, animated: false)
    }
}

class CustomSearchController: UISearchController {
    lazy var _searchBar: CustomSearchBar = {
        [unowned self] in
        let customSearchBar = CustomSearchBar(frame: CGRect.zero)
        return customSearchBar
        }()
    
    override var searchBar: UISearchBar {
        get {
            return _searchBar
        }
    }
}

extension UIImage {

    func resize(maxWidthHeight : Double)-> UIImage? {

        let actualHeight = Double(size.height)
        let actualWidth = Double(size.width)
        var maxWidth = 0.0
        var maxHeight = 0.0

        if actualWidth > actualHeight {
            maxWidth = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualWidth)
            maxHeight = (actualHeight * per) / 100.0
        }else{
            maxHeight = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualHeight)
            maxWidth = (actualWidth * per) / 100.0
        }

        let hasAlpha = true
        let scale: CGFloat = 0.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }

}
