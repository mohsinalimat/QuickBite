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

class AccountDetailsViewController: UIViewController, UITextFieldDelegate, MaskedTextFieldDelegateListener {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: TweeAttributedTextField!
    @IBOutlet weak var phoneTextField: TweeAttributedTextField!
    @IBOutlet weak var saveChangesButton: PMSuperButton!
    @IBOutlet weak var saveChangesButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var maskedListener: MaskedTextFieldDelegate!
    
    private var user: User!
    private var phoneEntryIsValid = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        if (nameTextField.text! == user.name && phoneTextField.text! == user.phone) || nameTextField.text!.isEmpty || !phoneEntryIsValid {
            saveChangesButton.setEnabled(false, actuallyEnableOrDisable: true)
        } else {
            saveChangesButton.setEnabled(true, actuallyEnableOrDisable: true)
        }
    }
    
    @IBAction func saveChangesTapped(_ sender: Any) {
        nameTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
        UserUtil.setName(nameTextField.text!)
        UserUtil.setPhoneNumber(phoneTextField.text!)
        
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
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        scrollView.contentInset.bottom = keyboardFrame.size.height
        saveChangesButtonBottomConstraint.constant = keyboardFrame.size.height - saveChangesButton.frame.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        saveChangesButtonBottomConstraint.constant = 16
    }
}
