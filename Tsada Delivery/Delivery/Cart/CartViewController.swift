//
//  CartViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/30/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton
import FittedSheets

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectPaymentMethodDelegate {
    @IBOutlet weak var cartRestaurantAndTotalQuantity: UILabel!
    @IBOutlet weak var cartItemsTableView: AutoSizedTableView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var topBarShadow: GradientView!
    @IBOutlet weak var removeAllButton: UIButton!
    @IBOutlet weak var addMoreItemsButton: UIButton!
    @IBOutlet weak var cartTotalPriceLabel: UILabel!
    @IBOutlet weak var deliveryFeePriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var bottomFadeView: UIView!
    @IBOutlet weak var continueButton: PMSuperButton!
    
    private var topBarShadowIsShown = false
    
    private var cartItems: [MenuItem] = []
    
    private var sheetController: SheetViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartItems = Cart.items
        
        deliveryFeePriceLabel.text = 50.asPriceString
        
        cartItemsTableView.rowHeight = UITableView.automaticDimension
        cartItemsTableView.estimatedRowHeight = 150
        
        bottomFadeView.fadeView(style: .top, percentage: 0.9)
        
        updateAddMoreItemsButtonVisibility()
        updateCartRestaurantAndTotalQuantityLabel()
        updatePriceLabels()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(self, action: #selector(closeSelf), imageName: "close")
    }
    
    private func updateCartRestaurantAndTotalQuantityLabel() {
        let s = cartItems.count > 1 ? "s" : ""
        cartRestaurantAndTotalQuantity.text = "\(Cart.restaurant!.name) · \(cartItems.count) item\(s)"
    }
    
    private func updateAddMoreItemsButtonVisibility() {
        addMoreItemsButton.isHidden = cartItems.count >= 10
    }
    
    private func updatePriceLabels() {
        let cartTotalPrice = Cart.totalPrice
        cartTotalPriceLabel.text = cartTotalPrice.asPriceString
        totalPriceLabel.text = cartTotalPrice == 0 ? 0.asPriceString : (cartTotalPrice + 50).asPriceString
    }
    
    // MARK: - Actions
    @IBAction func removeAllTapped(_ sender: Any) {
        Cart.empty()
        updatePriceLabels()
        continueButton.isEnabled = false
        UIView.animate(withDuration: 0.23, delay: 0, options: .curveEaseInOut, animations: {
            self.cartItemsTableView.frame.origin.x = -(self.cartItemsTableView.frame.width/2)
            self.cartItemsTableView.alpha = 0
        }) { _ in
            self.cartItems.removeAll()
            Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func addMoreItemsTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: UDKeys.redirectToCartRestaurant)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
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
            switch paymentMethod {
            case .cash:
                self.continueToNextScreen()
            case .gcash:
                if UserDefaults.standard.bool(forKey: UDKeys.gcashDontShowInfoScreen) {
                    self.continueToNextScreen()
                } else {
                    self.performSegue(withIdentifier: "ShowGCashInfoSegue", sender: nil)
                }
            case .card:
                break
            }
        })
    }
    
    private func continueToNextScreen() {
        if let user = UserUtil.currentUser, user.name.isNotEmpty, user.phone.isNotEmpty {
            performSegue(withIdentifier: "ReviewOrderSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "FinalizeOrderSegue", sender: nil)
        }
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemTableViewCell
        
        let cartItem = cartItems[indexPath.row]
        if cartItem.imageUrl.isNotEmpty {
            cell.itemImage.sd_setImage(with: URL(string: cartItem.imageUrl), placeholderImage: UIImage(named: "tertiary_system_grouped_background"))
        } else {
            cell.itemImage.removeFromSuperview()
        }
        cell.itemTitle.text = cartItem.itemName
        cell.selectedItemOptions.text = cartItem.selectedOptions
        cell.specialInstructions.text = cartItem.specialInstructions
        cell.quantityLabel.text = "\(cartItem.selectedQuantity)x"
        cell.priceLabel.text = cartItem.finalPrice.asPriceString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cartItems.remove(at: indexPath.row)
            Cart.removeItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            updateCartRestaurantAndTotalQuantityLabel()
            updateAddMoreItemsButtonVisibility()
            updatePriceLabels()
            
            if cartItems.isEmpty {
                removeAllButton.isEnabled = false
            }
        }
    }
}

extension CartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let shouldShowTopBarShadow = scrollView.contentOffset.y > 0
        if shouldShowTopBarShadow != topBarShadowIsShown {
            UIView.animate(withDuration: 0.1) {
                self.topBarShadow.alpha = self.topBarShadowIsShown ? 0.0 : 1.0
            }
            topBarShadowIsShown = !topBarShadowIsShown
        }
    }
}

class CartItemTableViewCell: UITableViewCell {
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var selectedItemOptions: UILabel!
    @IBOutlet weak var specialInstructions: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
