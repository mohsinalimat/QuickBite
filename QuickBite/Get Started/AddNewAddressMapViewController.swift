//
//  AddNewAddressMapViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMaps
import GooglePlaces
import CocoaLumberjack
import NVActivityIndicatorView
import PMSuperButton

class AddNewAddressMapViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabelCover: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var floorDoorUnitTextField: TweeAttributedTextField!
    @IBOutlet weak var buildingLandmarkTextField: TweeAttributedTextField!
    @IBOutlet weak var instructionsTextField: TweeAttributedTextField!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var renameButtonImage: UIImageView!
    @IBOutlet weak var cancelRenameButton: UIButton!
    @IBOutlet weak var geocoderIndicatorContainerView: UIView!
    @IBOutlet weak var geocoderActivityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var saveAddressButton: PMSuperButton!
    
    var address: GMSPlace! // Set by AddNewAddressSearchViewController
    private let geocoder = GMSGeocoder()
    
    private var gmsAddress: GMSAddress?
    private var userStreetNickname: String?
    
    private var saveWasTapped = false // Used to detect if the user hit the back button

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        geocoderActivityIndicator.startAnimating()

        let camera = GMSCameraPosition.camera(withLatitude: address.coordinate.latitude, longitude: address.coordinate.longitude, zoom: 17.5)
        mapView.delegate = self
        mapView.camera = camera
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if saveWasTapped == false {
            // User is going backwards to GetStartedViewController
            // Log out user if there is a user logged in
            try? Auth.auth().signOut()
            UserUtil.clearCurrentUser()
        }
    }
    
    // MARK: - MapView
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        // Map was moved -> reset userStreetNickname & show reverseGeocoder loading indicator
        geocoderIndicatorContainerView.alpha = 1
        userStreetNickname = nil
        saveAddressButton.isEnabled = false
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
            if let err = error {
                DDLogError("Error reverse geocoding: \(err)")
                return
            }
            
            if let result = response?.firstResult() {
                if let line1 = result.lines?[0] {
                    self.setAddressLabels(line1)
                    self.geocoderIndicatorContainerView.alpha = 0
                    self.saveAddressButton.isEnabled = true
                }
                self.gmsAddress = result
                DDLogDebug("\(String(describing: result.lines))")
            }
        }
    }
    
    private func setAddressLabels(_ address: String) {
        addressLabelCover.text = address.gmsStreet ?? "Unknown address"
    }
    
    // MARK: - UITextFieldDelegate
    // When user swipes down after editing or hits done button
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == addressTextField {
            guard addressTextField.text!.isNotEmpty else {
                // user stopped editing with no text in textfield
                cancelRenameTapped(self)
                return
            }
            
            if addressTextField.text! != addressLabelCover.text! {
                // user entered unique text
                // check above ensures user did not leave the text unedited
                userStreetNickname = addressTextField.text
                addressLabelCover.text = addressTextField.text
            }
            
            addressTextField.alpha = 0
            addressLabelCover.alpha = 1
            toggleNicknameEditingMode(false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    // MARK: - Actions
    @IBAction func renameTapped(_ sender: Any) {
        addressTextField.text = addressLabelCover.text
        toggleNicknameEditingMode(true)
        addressTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelRenameTapped(_ sender: Any) {
        addressTextField.resignFirstResponder()
        toggleNicknameEditingMode(false)
    }
    
    private func toggleNicknameEditingMode(_ isEditing: Bool) {
        addressTextField.alpha = isEditing ? 1 : 0
        addressLabelCover.alpha = isEditing ? 0 : 1
        
        renameButton.hide(isEditing)
        renameButtonImage.hide(isEditing)
        
        cancelRenameButton.hide(!isEditing)
    }
    
    @IBAction func saveAddressTapped(_ sender: Any) {
        guard let latitude = gmsAddress?.coordinate.latitude,
            let longitude = gmsAddress?.coordinate.longitude else {
                DDLogError("ERROR PARSING LAT LONG")
                // SHOW ERROR MESSAGE
                return
        }
        
        saveWasTapped = true
        
        let makeDefault = UserUtil.currentUser!.addresses.count == 0
        
        let address = Address(userNickname: userStreetNickname ?? "",
                              floorDoorUnitNo: floorDoorUnitTextField.text ?? "",
                              street: gmsAddress?.lines?[0].gmsStreet ?? "",
                              buildingLandmark: buildingLandmarkTextField.text ?? "",
                              instructions: instructionsTextField.text ?? "",
                              latitude: latitude,
                              longitude: longitude,
                              isSelected: true,
                              isDefault: makeDefault)
        
        UserUtil.addAddress(address)
        
        continueToMainDelivery()
    }
    
    private func continueToMainDelivery() {
        AppManager.shared.resetVCStack()
    }
    
    // MARK: - Keyboard Events
    @objc private func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        
        // Disable map dragging
        mapView.isUserInteractionEnabled = false
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        mapView.isUserInteractionEnabled = true
    }
}
