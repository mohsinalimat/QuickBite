//
//  CartViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/30/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var cartItemsTableView: AutoSizedTableView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var topBarShadow: GradientView!
    @IBOutlet weak var scrollViewTopView: UIView! // Dummy view used to track the top of scroll view's content. Used for showing/hiding topBarShadow
    @IBOutlet weak var removeAllButton: UIButton!
    @IBOutlet weak var cartTotalPriceLabel: UILabel!
    @IBOutlet weak var deliveryFeePriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var bottomFadeView: UIView!
    @IBOutlet weak var continueButton: PMSuperButton!
    
    private var topBarShadowIsShown = false
    
    private var cartItems: [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        cartItems = Cart.getItems()
        
        deliveryFeePriceLabel.text = 50.asPriceString
        
        cartItemsTableView.rowHeight = UITableView.automaticDimension
        cartItemsTableView.estimatedRowHeight = 100
        
        bottomFadeView.fadeView(style: .top, percentage: 0.9)
        
        updatePriceLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func updatePriceLabels() {
        let cartTotalPrice = Cart.totalPrice
        cartTotalPriceLabel.text = cartTotalPrice.asPriceString
        totalPriceLabel.text = cartTotalPrice == 0 ? 0.asPriceString : (cartTotalPrice + 50).asPriceString
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeAllTapped(_ sender: Any) {
        Cart.removeAll()
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
    
    @IBAction func continueTapped(_ sender: Any) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemTableViewCell
        
        let cartItem = cartItems[indexPath.row]
        cell.itemTitle.text = cartItem.itemName
        cell.selectedItemOptions.text = cartItem.selectedOptions
        cell.quantityLabel.text = "\(cartItem.selectedQuantity)x"
        cell.priceLabel.text = (cartItems[indexPath.row].price * Double(cartItem.selectedQuantity)).asPriceString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cartItems.remove(at: indexPath.row)
            Cart.removeItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            updatePriceLabels()
            
            if cartItems.isEmpty {
                removeAllButton.isEnabled = false
            }
            
        }
    }
}

extension CartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if shouldShowTopBarShadow != topBarShadowIsShown {
            UIView.animate(withDuration: 0.1) {
                self.topBarShadow.alpha = self.topBarShadowIsShown ? 0.0 : 1.0
            }
            topBarShadowIsShown = !topBarShadowIsShown
        }
    }
    
    private var shouldShowTopBarShadow: Bool {
        let frame = scrollViewTopView.convert(scrollViewTopView.bounds, to: nil)
        return frame.origin.y < topBar.frame.height
    }
}
