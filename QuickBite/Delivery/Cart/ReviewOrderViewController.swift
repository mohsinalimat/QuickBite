//
//  ReviewOrderViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/2/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton
import FirebaseFirestore
import NVActivityIndicatorView
import CocoaLumberjack


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
    
    @IBOutlet weak var placeOrderActivityIndicator: NVActivityIndicatorView!
    
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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        changeTextField.tweePlaceholder = String(Int(orderTotal))
        
        bottomFadeView.fadeView(style: .top, percentage: 0.35)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        if let value = Double(textField.text!) {
            changeAmountIsValid = (orderTotal.isLess(than: value) || orderTotal.isEqual(to: value))
        } else {
            changeTextField.tweePlaceholder = String(Int(orderTotal))
            changeAmountIsValid = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeTextField.tweePlaceholder = ""
        changePopUp.hide()
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
    
    private func showChangePopup(_ show: Bool) {
        
    }
    
    private func populateContactInfo() {
        let nameString = userName ?? UserUtil.currentUser!.name
        let phoneString = userPhone ?? UserUtil.currentUser!.phone
        
        contactInfoLabel.text = nameString + "\n" + phoneString
    }
    
    private func populateOrderTotal() {
        let cartQuantity = Cart.totalQuantity
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
            placeOrderButton.isEnabled = false
            saveUserInformation()
            placeOrder()
        } else {
            changePopUp.shake()
        }
    }
    
    private func saveUserInformation() {
        if let newName = userName {
            UserUtil.setName(newName)
        }
        
        if let newPhone = userPhone {
            UserUtil.setPhoneNumber(newPhone)
        }
    }
    
    private func placeOrder() {
        let ordersDb = Firestore.firestore().collection("orders")
        
        let user = UserUtil.currentUser!
        let restaurant = Cart.restaurant!
        let order = Order(customerName: user.name,
                          customerContactNumber: user.phone,
                          deliveryAddress: user.selectedAddress.toString(),
                          restaurantName: restaurant.name,
                          restaurantAddress: restaurant.address,
                          restaurantContactNumber: restaurant.contactNumber,
                          restaurantImageUrl: restaurant.imageURL,
                          datePlaced: Date(),
                          items: Cart.items,
                          total: Cart.totalPrice,
                          changeFor: Double(changeTextField.text!)!,
                          isPendingCompletion: true)
        
        UserUtil.addCurrentOrder(order)
        
        ordersDb.document(order.id.uuidString).setData(order.dictionary) { err in
            if let err = err {
                DDLogError("Error submitting order: \(err)")
                // SHOW ERROR MESSAGE
                return
            }
            // Order placed!
            // 1. Stop animating indicatory
            // 2. Show order placed alert
            // 3. Set flag so tabbar knows to navigate to orders page
            // 4. Clear cart contents
            self.placeOrderActivityIndicator.stopAnimating()
            self.showOrderPlacedAlert()
            UserDefaults.standard.set(true, forKey: UDKeys.redirectToOrders)
            Cart.empty()
        }
        
        // Animate
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.placeOrderButton.titleLabel?.alpha = 0.0
        }) { _ in
            self.placeOrderActivityIndicator.startAnimating()
            UIView.animate(withDuration: 0.1, animations: {
                self.placeOrderActivityIndicator.alpha = 1.0
            })
        }
    }
    
    private func showOrderPlacedAlert() {
        let alertView = SPAlertView(title: "Order Placed", message: nil, preset: .done)
        alertView.duration = 2.5
        alertView.dismissByTap = false
        alertView.present()
        startDismissTimer()
    }
    
    private func startDismissTimer() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.dismiss(animated: true, completion: nil)
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
