//
//  FinalizeOrderViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/18/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton
import InputMask
import KeyboardLayoutGuide

class FinalizeOrderViewController: UIViewController, UITextFieldDelegate, MaskedTextFieldDelegateListener {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var nameTextField: TweeAttributedTextField?
    @IBOutlet weak var phoneTextField: TweeAttributedTextField?
    @IBOutlet weak var continueButton: PMSuperButton!
    @IBOutlet var maskedListener: MaskedTextFieldDelegate!
    
    private var phoneEntryIsValid = false
    
    // Contact Info Mode, for when the user is changing their contact info from ReviewAndPlaceOrderViewController
    public var contactInfoMode = false
    public var reviewAndPlaceOrderVC: ReviewAndPlaceOrderViewController?
    public var name: String?
    public var phone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        continueButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8).isActive = true
        
        // Scroll view shit
        automaticallyAdjustsScrollViewInsets = false
        scrollView.contentInset = UIEdgeInsets.zero
        
        if contactInfoMode {
            header.text = "Contact Info"
            nameTextField?.becomeFirstResponder()
            continueButton.setTitle("Save", for: .normal)
            navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(self, action: #selector(closeSelf), imageName: "close")
            
            nameTextField?.text = name
            phoneTextField?.text = phone
            continueButton.setEnabled(true)
        } else {
            header.text = "Finalize your order from \(Cart.restaurant!.name)"
            
            if UserUtil.currentUser!.name.isNotEmpty {
                // Hide name field, set phone as firstResponder
                nameTextField?.removeFromSuperview()
                phoneTextField?.becomeFirstResponder()
            } else if UserUtil.currentUser!.phone.isNotEmpty {
                // Hide phone field, set name as firstResponder
                phoneTextField?.removeFromSuperview()
                nameTextField?.becomeFirstResponder()
            } else {
                // Hide neither, set name to be firstResponder
                nameTextField?.becomeFirstResponder()
            }
        }
        
        nameTextField?.addTarget(self, action: #selector(nameTextDidChange), for: UIControl.Event.editingChanged)
    }
    
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        phoneEntryIsValid = complete
        continueButton.setEnabled(textFieldsAreValid())
    }
    
    @objc func nameTextDidChange() {
        continueButton.setEnabled(textFieldsAreValid())
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
    
    private func showRequiredHints() {
        if let nameTF = nameTextField, nameTF.text!.isEmpty {
            nameTF.showRequiredHint()
        }
        
        if let phoneTF = phoneTextField, (!phoneEntryIsValid && phoneTF.text!.count != 16) {
            phoneTF.showRequiredHint()
        }
    }
    
    private func hideRequiredHints() {
        if let nameTF = nameTextField, nameTF.text!.isEmpty {
            nameTF.hideInfo()
        }
        
        if let phoneTF = phoneTextField, !phoneEntryIsValid {
            phoneTF.hideInfo()
        }
    }
    
    private func textFieldsAreValid() -> Bool {
        if let nameTF = nameTextField, nameTF.text!.isEmpty {
            return false
        }
        
        if let phoneTF = phoneTextField, (!phoneEntryIsValid && phoneTF.text!.count != 16) {
            return false
        }
        
        return true
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        if textFieldsAreValid() {
            hideRequiredHints()
            nameTextField?.resignFirstResponder()
            phoneTextField?.resignFirstResponder()
            if contactInfoMode {
                reviewAndPlaceOrderVC?.userName = nameTextField!.text!
                reviewAndPlaceOrderVC?.userPhone = phoneTextField!.text!
                closeSelf()
            } else {
                performSegue(withIdentifier: "ShowReviewOrderSegue", sender: nil)
            }
        } else {
            showRequiredHints()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let reviewOrderVC = segue.destination as? ReviewAndPlaceOrderViewController {
            // Pass user info. We're not saving the user info until the user hits place order.
            if let nameTF = nameTextField {
                reviewOrderVC.userName = nameTF.text!
            }
            
            if let phoneTF = phoneTextField {
                reviewOrderVC.userPhone = phoneTF.text!
            }
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        scrollView.contentInset.bottom = 0.1
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }

}
