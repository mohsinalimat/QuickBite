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

class FinalizeOrderViewController: UIViewController, UITextFieldDelegate, MaskedTextFieldDelegateListener {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var finalizeLabel: UILabel!
    @IBOutlet weak var nameTextField: TweeAttributedTextField?
    @IBOutlet weak var phoneTextField: TweeAttributedTextField?
    @IBOutlet weak var nextButton: PMSuperButton!
    @IBOutlet var maskedListener: MaskedTextFieldDelegate!
    
    private var phoneEntryIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        finalizeLabel.text = "Finalize your order from \(Cart.restaurant!.name)"
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        phoneEntryIsValid = complete
        enableNextButton(textFieldsAreValid())
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
        enableNextButton(textFieldsAreValid())
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
        scrollView.contentInset.bottom = 0
    }
    
    private func showRequiredHints() {
        if let nameTF = nameTextField, nameTF.text!.isEmpty {
            showRequiredHint(nameTF)
        }
        
        if let phoneTF = phoneTextField, !phoneEntryIsValid {
            showRequiredHint(phoneTF)
        }
    }
    
    private func showRequiredHint(_ textField: TweeAttributedTextField) {
        textField.infoTextColor = #colorLiteral(red: 0.9361338615, green: 0.3251743913, blue: 0.3114004433, alpha: 1)
        let required = "required"
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold).smallCaps()
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.kern: -0.4 ] as [NSAttributedString.Key : Any]
        textField.showInfo(NSAttributedString(string: required, attributes: attributes), animated: true)
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
        if textFieldsAreValid() {
            hideRequiredHints()
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

}
