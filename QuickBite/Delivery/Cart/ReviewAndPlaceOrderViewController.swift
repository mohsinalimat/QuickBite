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
import Reachability
import CocoaLumberjack
import FittedSheets

class ReviewAndPlaceOrderViewController: UIViewController, SelectPaymentMethodDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomFadeView: UIView!
    
    @IBOutlet weak var placeOrderButton: PMSuperButton!

    // Information
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var unitAndStreet: UILabel!
    @IBOutlet weak var buildingLandmark: UILabel!
    @IBOutlet weak var instructions: UILabel!
    
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var deliveryEstimate: UILabel!
    @IBOutlet weak var paymentMethod: UILabel!
    
    @IBOutlet weak var placeOrderActivityIndicator: NVActivityIndicatorView!
    
    private var sheetController: SheetViewController?
    
    private let reachability = Reachability()!
    private var isNetworkReachable = true
    
    public var userName: String?
    public var userPhone: String?
    
    private var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachability()
        populateOrderDetails()
        bottomFadeView.fadeView(style: .top, percentage: 0.35)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = UserUtil.currentUser!
        populateAddress()
        populateContactInfo()
        populateDeliveryEstimate()
        populatePaymentMethod()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
    }
    
    private func setupReachability() {
        reachability.whenReachable = { reachability in
            self.isNetworkReachable = true
        }
        reachability.whenUnreachable = { _ in
            self.isNetworkReachable = false
        }

        do {
            try reachability.startNotifier()
        } catch {
            DDLogDebug("Unable to start notifier")
        }
    }
    
    // MARK: - Populate Fields
    private func populateAddress() {
        let address = user.selectedAddress
        
        addressName.text = address.displayName
        
        // Calculate second line
        if address.floorDoorUnitNo.isNotEmpty {
            if address.userNickname.isNotEmpty {
                // First line is set to user nickname, so append street
                unitAndStreet.text = address.floorDoorUnitNo + ", " + address.street
            } else {
                unitAndStreet.text = address.floorDoorUnitNo
            }
        } else if address.userNickname.isNotEmpty {
            // No unit or floor set, but there is a userNickname
            unitAndStreet.text = address.street
        } else if let unitStreet = unitAndStreet {
            // No unit or floor and no userNickname, hide second line
            unitStreet.removeFromSuperview()
        }
        
        if address.buildingLandmark.isNotEmpty {
            buildingLandmark.text = address.buildingLandmark
        } else if let bdLandmark = buildingLandmark{
            bdLandmark.removeFromSuperview()
        }
        
        if address.instructions.isNotEmpty {
            instructions.text = "Instructions: " + address.instructions
        } else if let instr = instructions {
            instr.removeFromSuperview()
        }
    }
    
    private func populateContactInfo() {
        let nameString = userName ?? UserUtil.currentUser!.name
        let phoneString = userPhone ?? UserUtil.currentUser!.phone
        
        contactInfoLabel.text = nameString + "\n" + phoneString
    }
    
    private func populateOrderDetails() {
        let cartQuantity = Cart.totalQuantity
        let s = cartQuantity > 1 ? "s" : ""
        orderLabel.text = "\(cartQuantity) item\(s) from \(Cart.restaurant!.name)\nTotal \(Cart.totalPrice.asPriceString)"
    }
    
    private func populateDeliveryEstimate() {
        // Must calculate DistanceTime instead of reading DistanceTime from restaurant
        // because the user may add a new address on this screen
        self.deliveryEstimate.isHidden = true
        DistanceTimeUtil.getDistanceTimes([Cart.restaurant!], forAddress: user.selectedAddress) { (result, error) in
            self.deliveryEstimate.text = result?[Cart.restaurant!.id]!.time
            self.deliveryEstimate.isHidden = false
        }
    }
    
    private func populatePaymentMethod() {
        paymentMethod.text = Cart.paymentMethod!.rawValue
    }
    
    // MARK: - Actions
    @IBAction func changeAddressTapped(_ sender: Any) {
        let accountStoryboard = UIStoryboard(name: "Account", bundle: nil)
        let addressesVC = accountStoryboard.instantiateViewController(withIdentifier: "AddressesVC")
        
        presentInSeparateNavController(addressesVC, animated: true)
    }
    
    @IBAction func changeContactInfoTapped(_ sender: Any) {
        let contactInfoVC = storyboard!.instantiateViewController(withIdentifier: "FinalizeOrderVC") as! FinalizeOrderViewController
        contactInfoVC.reviewAndPlaceOrderVC = self
        contactInfoVC.contactInfoMode = true
        contactInfoVC.name = contactInfoLabel.text!.chompAt("\n")
        contactInfoVC.phone = String(contactInfoLabel.text!.split(separator: "\n").last!)
        presentInSeparateNavController(contactInfoVC, animated: true)
    }
    
    
    @IBAction func changePaymentMethodTapped(_ sender: Any) {
        let paymentMethodVC = storyboard!.instantiateViewController(withIdentifier: "SelectPaymentMethodVC") as! SelectPaymentMethodViewController
        paymentMethodVC.delegate = self
        sheetController = SheetViewController(controller: paymentMethodVC, sizes: [.fixed(250)])
        sheetController?.extendBackgroundBehindHandle = true
        sheetController?.handleColor = .systemBackgroundCompat
        sheetController?.blurBottomSafeArea = false
        sheetController?.topCornersRadius = 15
        present(sheetController!, animated: false)
    }
    
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod) {
        sheetController?.closeSheet(completion: {
            // Show GCash info screen
            if paymentMethod == .gcash && UserDefaults.standard.bool(forKey: UDKeys.gcashDontShowInfoScreen) == false {
                let gcashInfoVC = self.storyboard!.instantiateViewController(withIdentifier: "GCashInfoVC") as! GCashInfoViewController
                gcashInfoVC.showModally = true
                self.presentInSeparateNavController(gcashInfoVC, animated: true)
            }
        })
    }
    
    @IBAction func placeOrderTapped(_ sender: Any) {
        guard isNetworkReachable else {
            let alert = UIAlertController(title: "Error Placing Order",
                                          message: "Please check your internet connection and try again.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // Show confirmation alert
        let alert = UIAlertController(title: "Confirm Order",
                                      message: "You are about to place an order from \(Cart.restaurant!.name).",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            self.saveUserInformation()
            self.placeOrder()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Place Order
    private func saveUserInformation() {
        // Only save info if the currently saved name and phone are empty.
        if let newName = userName, UserUtil.currentUser!.name.isEmpty {
            UserUtil.setName(newName)
        }
        
        if let newPhone = userPhone, UserUtil.currentUser!.phone.isEmpty {
            UserUtil.setPhoneNumber(newPhone)
        }
    }
    
    private func placeOrder() {
        placeOrderButton.isEnabled = false
        
        // Show activity indicator
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.placeOrderButton.titleLabel?.alpha = 0.0
        }) { _ in
            self.placeOrderActivityIndicator.startAnimating()
            UIView.animate(withDuration: 0.1, animations: {
                self.placeOrderActivityIndicator.alpha = 1.0
            })
        }
        
        let ordersDb = Firestore.firestore().collection("orders")
        
        let user = UserUtil.currentUser!
        let restaurant = Cart.restaurant!
        let order = Order(customerName: contactInfoLabel.text!.chompAt("\n"),
                          customerContactNumber: String(contactInfoLabel.text!.split(separator: "\n").last!),
                          deliveryAddress: user.selectedAddress.toString(),
                          restaurantName: restaurant.name,
                          restaurantAddress: restaurant.address,
                          restaurantContactNumber: restaurant.contactNumber,
                          restaurantImageUrl: restaurant.imageURL,
                          datePlaced: Date(),
                          items: Cart.items,
                          total: Cart.totalPrice,
                          paymentMethod: Cart.paymentMethod!.rawValue,
                          isPendingCompletion: true)
        
        UserUtil.addCurrentOrder(order)
        
        ordersDb.document(order.id.uuidString).setData(order.dictionary) { err in
            if let err = err {
                DDLogError("Error submitting order: \(err)")
                self.placeOrderActivityIndicator.alpha = 0.0
                self.placeOrderButton.titleLabel?.alpha = 1.0
                self.placeOrderButton.isEnabled = true
                
                let alert = UIAlertController(title: "Error Placing Order",
                                              message: "Unable to place order. Please contact us by tapping \"Submit an Issue\" on your Account page.",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            // Order placed!
            // 1. Stop animating indicator
            // 2. Show order placed alert
            // 3. Set flag so tabbar knows to navigate to orders page
            // 4. Clear cart contents
            self.placeOrderActivityIndicator.stopAnimating()
            self.showOrderPlacedAlert()
            UserDefaults.standard.set(true, forKey: UDKeys.redirectToOrders)
            Cart.empty()
        }
    }
    
    private func showOrderPlacedAlert() {
        let alertView = SPAlertView(title: "Order Placed", message: nil, preset: .done)
        alertView.duration = 1.5
        alertView.dismissByTap = false
        alertView.present()
        startDismissTimer()
    }
    
    private func startDismissTimer() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
