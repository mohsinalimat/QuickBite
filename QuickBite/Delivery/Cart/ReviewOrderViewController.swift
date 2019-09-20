//
//  ReviewOrderViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/2/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton

class ReviewOrderViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomFadeView: UIView!
    
    // Buttons
    @IBOutlet weak var editAddressButton: UIButton!
    @IBOutlet weak var editContactInfoButton: UIButton!
    @IBOutlet weak var placeOrderButton: PMSuperButton!
    
    // Information
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    
    @IBOutlet weak var changeTextField: TweeAttributedTextField!
    
    @IBOutlet weak var changePopUp: MiniPopupView!
    
    private var orderTotal: Double!
    
    // Set by presenting view controller
    var userName: String?
    var userPhone: String?
    
    private var changeAmountIsValid = false {
        didSet {
            enablePlaceOrderButton(changeAmountIsValid)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderTotal = Cart.totalPrice
        
        populateContactInfo()
        populateOrderTotal()

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        changeTextField.tweePlaceholder = String(Int(orderTotal))
        
        bottomFadeView.fadeView(style: .top, percentage: 0.35)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changePopUp.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = Double(textField.text!)!
        changeAmountIsValid = orderTotal.isLess(than: value)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeTextField.tweePlaceholder = ""
        changePopUp.hide()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 80
        scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    private func showChangePopup(_ show: Bool) {
        
    }
    
    private func populateContactInfo() {
        let nameString = userName ?? UserUtil.currentUser!.name
        let phoneString = userPhone ?? UserUtil.currentUser!.phone
        
        contactInfoLabel.text = nameString + "\n" + phoneString
    }
    
    private func populateOrderTotal() {
        let cartQuantity = Cart.getTotalQuantity()
        let s = cartQuantity > 1 ? "s" : ""
        orderLabel.text = "\(cartQuantity) item\(s) - \(Cart.totalPrice.asPriceString)"
    }
    
    private func enablePlaceOrderButton(_ enable: Bool) {
        if enable {
            placeOrderButton.gradientStartColor = #colorLiteral(red: 0.9361338615, green: 0.3251743913, blue: 0.3114004433, alpha: 1)
            placeOrderButton.gradientEndColor = #colorLiteral(red: 1, green: 0.3441041454, blue: 0.3272007855, alpha: 0.8)
            placeOrderButton.shadowOpacity = 0.25
        } else {
            placeOrderButton.gradientStartColor = #colorLiteral(red: 0.832096374, green: 0.832096374, blue: 0.832096374, alpha: 1)
            placeOrderButton.gradientEndColor = #colorLiteral(red: 0.832096374, green: 0.832096374, blue: 0.832096374, alpha: 1)
            placeOrderButton.shadowOpacity = 0
        }
    }
    
    @IBAction func placeOrderTapped(_ sender: Any) {
        if changeAmountIsValid {
            
        } else {
            changePopUp.shake()
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
