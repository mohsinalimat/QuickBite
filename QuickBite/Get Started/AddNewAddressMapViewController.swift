//
//  AddNewAddressMapViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
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
    @IBOutlet weak var pinHintView: UIView!
    
    var selectedAddress: GMSPlace! // Set by AddNewAddressSearchViewController
    private let geocoder = GMSGeocoder()
    
    private var mapCenterMarkerAddress: GMSAddress?
    private var userStreetNickname: String?
    private var mapViewWasMoved = false
    private var pinHintIsShown = false
    
    var firstTimeSetupMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        geocoderActivityIndicator.startAnimating()

        let camera = GMSCameraPosition.camera(withLatitude: selectedAddress.coordinate.latitude, longitude: selectedAddress.coordinate.longitude, zoom: 17.5)
        mapView.delegate = self
        mapView.camera = camera
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPleaseMoveHint(true)
    }
    
    private func showPleaseMoveHint(_ show: Bool) {
        guard pinHintIsShown != show else { return }
        pinHintIsShown = show
        DispatchQueue.main.async {
            // Must be called on main thread because mapView(willMove) gets called on background thread
            UIView.animate(withDuration: 0.4, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 9.5, options: .curveEaseOut, animations: {
                self.pinHintView.frame.origin.y += show ? 58 : -58
            }, completion: nil)
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
                self.mapCenterMarkerAddress = result
                DDLogDebug("\(String(describing: result.lines))")
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        showPleaseMoveHint(false)
        mapViewWasMoved = true
    }
    
    private func setAddressLabels(_ address: String) {
        guard mapViewWasMoved else {
            addressLabelCover.text = self.selectedAddress.formattedAddress?.gmsStreet
            return
        }
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
        guard let latitude = mapCenterMarkerAddress?.coordinate.latitude,
            let longitude = mapCenterMarkerAddress?.coordinate.longitude else {
                DDLogError("ERROR PARSING LAT LONG")
                // SHOW ERROR MESSAGE
                return
        }
        
        let userNickname = userStreetNickname ?? selectedAddress.formattedAddress?.gmsStreet
        
        let makeDefault = UserUtil.currentUser!.addresses.count == 0
        
        let newAddress = Address(userNickname: userNickname ?? "",
                              floorDoorUnitNo: floorDoorUnitTextField.text ?? "",
                              street: mapCenterMarkerAddress?.lines?[0].gmsStreet ?? "",
                              buildingLandmark: buildingLandmarkTextField.text ?? "",
                              instructions: instructionsTextField.text ?? "",
                              latitude: latitude,
                              longitude: longitude,
                              isSelected: true,
                              isDefault: makeDefault)
        
        UserUtil.addAddress(newAddress)
        
        if firstTimeSetupMode {
            continueToMainDelivery()
        } else {
            navigationController?.popBack(2)
        }
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
        
        scrollView.contentInset.bottom = keyboardFrame.size.height
        
        // Disable map dragging
        mapView.isUserInteractionEnabled = false
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        mapView.isUserInteractionEnabled = true
    }
}
