//
//  UserPrefsViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/24/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton
import InputMask
import CocoaLumberjack
import KeyboardLayoutGuide

class AccountDetailsViewController: UIViewController, UITextFieldDelegate, MaskedTextFieldDelegateListener {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: TweeAttributedTextField!
    @IBOutlet weak var phoneTextField: TweeAttributedTextField!
    @IBOutlet weak var saveChangesButton: PMSuperButton!
    @IBOutlet var maskedListener: MaskedTextFieldDelegate! 
    
    private var user: User!
    private var phoneEntryIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Scroll view shit
        automaticallyAdjustsScrollViewInsets = false
        scrollView.contentInset = UIEdgeInsets.zero
        
        saveChangesButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8).isActive = true
        
        user = UserUtil.currentUser!
        
        nameTextField.text = user.name
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        if user.phone.isNotEmpty {
            phoneTextField.text = user.phone
            phoneEntryIsValid = true
        }
    }
    
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        phoneEntryIsValid = complete
        refreshSaveButton()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        refreshSaveButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    private func refreshSaveButton() {
        var nameTextFieldIsValid = false
        if user.name.isEmpty { // Saved user name was empty when screen was opened. So just check if it's empty
            if nameTextField.text!.isNotEmpty {
                nameTextFieldIsValid = true
            }
        } else { // Saved user name had some characters in it.
            if nameTextField.text! != user.name && nameTextField.text!.isNotEmpty {
                nameTextFieldIsValid = true
            }
        }
        
        let phoneFieldIsValid = phoneEntryIsValid && phoneTextField.text!.count > 3
        
        let enableSaveButton = nameTextFieldIsValid || phoneFieldIsValid
        saveChangesButton.setEnabled(enableSaveButton, actuallyEnableOrDisable: true)
    }
    
    @IBAction func saveChangesTapped(_ sender: Any) {
        nameTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
        UserUtil.setName(nameTextField.text!)
        if phoneEntryIsValid {
            UserUtil.setPhoneNumber(phoneTextField.text!)
        }
        
        let alertView = SPAlertView(title: "Changes Saved", message: nil, preset: .done)
        alertView.duration = 1
        alertView.dismissByTap = false
        alertView.present()
        
        Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { _ in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Keyboard Events
    @objc private func keyboardWillShow(notification: NSNotification) {
        scrollView.contentInset.bottom = 0.1
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
}
