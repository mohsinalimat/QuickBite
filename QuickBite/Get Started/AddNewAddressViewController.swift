//
//  AddNewAddressViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/13/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton
import FirebaseAuth
import CocoaLumberjack

class AddNewAddressViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var greetingLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var nextButton: PMSuperButton!
    
    // TextFields
    @IBOutlet weak var floorDeptHouseNoTextField: TweeAttributedTextField!
    @IBOutlet weak var streetTextField: TweeAttributedTextField!
    @IBOutlet weak var barangayTextField: TweeAttributedTextField!
    @IBOutlet weak var buildingTextField: TweeAttributedTextField!
    @IBOutlet weak var landmarkTextField: TweeAttributedTextField!
    
    private final let streetTextFieldTag = 1
    
    private var nextWasTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let userFirstName = Auth.auth().currentUser?.displayName?.chompAt(" ") {
            greetingLabel.text = "Hi, \(userFirstName)!"
        } else {
            greetingLabelHeight.constant = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if nextWasTapped == false {
            // User is going backwards to GetStartedViewController
            // Log out user if there is a user logged in
            try? Auth.auth().signOut()
            UserUtil.clearCurrentUser()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = view.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        enableNextButton(checkAddressRequirements())
    }
    
    private func checkAddressRequirements() -> Bool {
        if let streetText = streetTextField.text, streetText.isNotEmpty {
            streetTextField.hideInfo()
            return true
        }
        return false
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 80
        scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func showRequiredHints() {
        streetTextField.infoTextColor = #colorLiteral(red: 0.9361338615, green: 0.3251743913, blue: 0.3114004433, alpha: 1)
        let required = "required"
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold).smallCaps()
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.kern: -0.4 ] as [NSAttributedString.Key : Any]
        streetTextField.showInfo(NSAttributedString(string: required, attributes: attributes), animated: true)
        streetTextField.becomeFirstResponder()
    }
    
    private func createAndSaveAddress() {
//        let newAddress = Address(floorDeptHouseNo: floorDeptHouseNoTextField.text ?? "",
//                                 street: streetTextField.text ?? "",
//                                 barangay: barangayTextField.text ?? "",
//                                 building: buildingTextField.text ?? "",
//                                 landmark: landmarkTextField.text ?? "",
//                                 isSelected: true,
//                                 isDefault: true)
//        
//        UserUtil.addAddress(newAddress)
    }
    
    private func enableNextButton(_ enable: Bool) {
        if enable {
            nextButton.gradientStartColor = #colorLiteral(red: 0.9361338615, green: 0.3251743913, blue: 0.3114004433, alpha: 1)
            nextButton.gradientEndColor = #colorLiteral(red: 1, green: 0.3441041454, blue: 0.3272007855, alpha: 0.8)
            nextButton.shadowOpacity = 0.25
        } else {
            nextButton.gradientStartColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            nextButton.gradientEndColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            nextButton.shadowOpacity = 0
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        nextWasTapped = true
        if checkAddressRequirements() {
            createAndSaveAddress()
            performSegue(withIdentifier: "ShowMainDeliveryFromAddNewAddress", sender: nil)
        } else {
            showRequiredHints()
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
