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
    @IBOutlet weak var finalizeLabel: UILabel!
    @IBOutlet weak var nameTextField: TweeAttributedTextField?
    @IBOutlet weak var phoneTextField: TweeAttributedTextField?
    @IBOutlet weak var continueButton: PMSuperButton!
    @IBOutlet var maskedListener: MaskedTextFieldDelegate!
    
    private var phoneEntryIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        finalizeLabel.text = "Finalize your order from \(Cart.restaurant!.name)"
        
        continueButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8).isActive = true
        
        // Scroll view shit
        automaticallyAdjustsScrollViewInsets = false
        scrollView.contentInset = UIEdgeInsets.zero
        
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
    
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        phoneEntryIsValid = complete
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        continueButton.setEnabled(textFieldsAreValid())
    }
    
    private func showRequiredHints() {
        if let nameTF = nameTextField, nameTF.text!.isEmpty {
            nameTF.showRequiredHint()
        }
        
        if let phoneTF = phoneTextField, !phoneEntryIsValid {
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
        
        if let _ = phoneTextField, !phoneEntryIsValid {
            return false
        }
        
        return true
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        if textFieldsAreValid() {
            hideRequiredHints()
            nameTextField?.resignFirstResponder()
            phoneTextField?.resignFirstResponder()
            performSegue(withIdentifier: "ShowReviewOrderSegue", sender: nil)
        } else {
            showRequiredHints()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let reviewOrderVC = segue.destination as? ReviewOrderViewController {
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
