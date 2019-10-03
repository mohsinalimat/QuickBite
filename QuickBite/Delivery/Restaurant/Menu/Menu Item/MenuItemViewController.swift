//
//  MenuItemViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol MenuItemViewControllerDelegate: class {
    func itemAddedToCart()
}

class MenuItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var orderOptionsTableView: UITableView!
    @IBOutlet weak var menuItemImage: UIImageView!
    @IBOutlet weak var menuItemTitle: UILabel!
    @IBOutlet weak var menuItemTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuItemTopBarTitle: UILabel!
    @IBOutlet weak var menuItemDescription: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var topBar: GradientView!
    @IBOutlet weak var topBarBackground: UIView!
    @IBOutlet weak var topBarShadow: GradientView!
    @IBOutlet weak var bottomFadeView: UIView!
    @IBOutlet weak var specialInstructionsTextField: TweeAttributedTextField!
    
    // Quantity Button
    @IBOutlet weak var decreaseQuantityBtn: UIButton!
    @IBOutlet weak var increaseQuantityBtn: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    
    private var ios13padding: CGFloat = 0
    
    var restaurant: Restaurant!
    var menuItem: MenuItem!
    
    weak var delegate: MenuItemViewControllerDelegate?
    
    private var addedPriceForSection: [Double]! {
        didSet { updateTotalPriceLabel() }
    }
    private var totalAddedPrice: Double {
        return addedPriceForSection.reduce(0, +)
    }
    
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if #available(iOS 13, *) {
            // Hide topBar gradient for iOS 13 devices
            topBar.topColor = .clear
            // FIXME:
            ios13padding = 40
        }
    
        if menuItem.imageUrl.isNotEmpty {
            menuItemImage.sd_setImage(with: URL(string: menuItem.imageUrl))
        } else {
            menuItemTitleTopConstraint.constant = 100
        }
        menuItemTitle.text = menuItem.itemName
        menuItemTopBarTitle.text = menuItem.itemName
        menuItemDescription.text = menuItem.description
        totalPriceLabel.text = menuItem.price.asPriceString
        
        scrollView.contentInset.bottom = 120
        
        addedPriceForSection = Array(repeating: 0.0, count: menuItem.itemOptionCategories.count)
        
        orderOptionsTableView.register(OrderOptionHeaderView.nib, forHeaderFooterViewReuseIdentifier: OrderOptionHeaderView.reuseIdentifier)
        orderOptionsTableView.rowHeight = UITableView.automaticDimension
        orderOptionsTableView.estimatedRowHeight = 60
        
        bottomFadeView.fadeView(style: .top, percentage: 0.35)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        scrollView.contentInset.bottom = keyboardFrame.size.height + 80
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderOptionHeaderView.reuseIdentifier) as! OrderOptionHeaderView
        let itemOptionCategory = menuItem.itemOptionCategories[section]
        header.orderOptionsTitle.text = itemOptionCategory.categoryName
        header.isSingleSelection = itemOptionCategory.isSingleSelection
        header.selectionIsRequired = itemOptionCategory.isRequired
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItem.itemOptionCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItem.itemOptionCategories[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderOptionCell", for: indexPath) as! OrderOptionTableViewCell
        
        let orderOption = menuItem.itemOptionCategories[indexPath.section]
        cell.label.text = orderOption.options[indexPath.row].stripPrice()
        if let price = orderOption.options[indexPath.row].getPrice() {
            cell.price.text = "add \(price.asPriceString)"
        }
        cell.checkbox.boxType = orderOption.isSingleSelection ? .circle : .square
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let header = tableView.headerView(forSection: indexPath.section) as! OrderOptionHeaderView
        if header.selectionIsRequired {
            header.requirementIsSatisfied()
        }
        
        let itemOptionCategory = menuItem.itemOptionCategories[indexPath.section]
        
        if header.isSingleSelection {
            // Deselect other rows in the same section
            for cellRow in 0..<tableView.numberOfRows(inSection: indexPath.section) {
                if cellRow != indexPath.row {
                    tableView.deselectRow(at: IndexPath(row: cellRow, section: indexPath.section), animated: true)
                }
            }
        }
        
        if let price = itemOptionCategory.options[indexPath.row].getPrice() {
            if header.isSingleSelection {
                addedPriceForSection[indexPath.section] = price
            } else {
                addedPriceForSection[indexPath.section] += price
            }
        }
    }
    
    // Prevent deselection for single selection sections
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let header = tableView.headerView(forSection: indexPath.section) as! OrderOptionHeaderView
        guard !header.isSingleSelection else { return nil }
        
        let orderOption = menuItem.itemOptionCategories[indexPath.section]
        if let price = orderOption.options[indexPath.row].getPrice() {
            addedPriceForSection[indexPath.section] -= price
        }
        
        return indexPath
    }
    
    
    // MARK: - Quantity Control
    @IBAction func decreaseQuantityTapped(_ sender: Any) {
        changeQuantity(increase: false)
    }
    
    @IBAction func increaseQuantityTapped(_ sender: Any) {
        changeQuantity(increase: true)
    }
    
    private func changeQuantity(increase: Bool) {
        let oldQuantity = Int(quantityLabel.text!)!
        let newQuantity = increase ? (oldQuantity + 1) : (oldQuantity - 1)
        
        decreaseQuantityBtn.isEnabled = !(newQuantity == 1)
        increaseQuantityBtn.isEnabled = !(newQuantity == 10)
        
        quantityLabel.text = String(newQuantity)
        updateTotalPriceLabel()
        selectionFeedbackGenerator.selectionChanged()
    }
    
    private func updateTotalPriceLabel() {
        let quantity = Double(quantityLabel.text!)!
        totalPriceLabel.text = (quantity * (menuItem.price + totalAddedPrice)).asPriceString
    }
    
    
    @IBAction func addToOrderTapped(_ addButton: UIButton) {
        if let cartRestaurant = Cart.restaurant, Cart.hasItems {
            if restaurant.id != cartRestaurant.id {
                // User is trying to add an item from a different restaurant
                let alert = UIAlertController(title: "Clear Your Cart?",
                                              message: "You already have items from \(cartRestaurant.name) in your cart. Adding this item will create a new cart with this item from \(restaurant.name).",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                    Cart.empty()
                    self.addToOrderTapped(addButton)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            if Cart.totalQuantity >= 10 {
                let alert = UIAlertController(title: "Cart Full",
                                              message: "Your cart already has the maximum number of items. Please remove some items or reduce the quantity of this item, then try again.",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
        }
        
        // Prevent double taps while "Added to Order" alert is showing
        addButton.isEnabled = false
        
        let alertView = SPAlertView(title: "Added to Order", message: nil, preset: .done)
        alertView.duration = 1
        alertView.dismissByTap = false
        alertView.present()
        
        var selectedOrderOptions = ""
        if let indexPaths = orderOptionsTableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                let selectedCell = orderOptionsTableView.cellForRow(at: indexPath) as! OrderOptionTableViewCell
                selectedOrderOptions.append("\(selectedCell.label.text!), ")
            }
            // Trim the extra ", " from the end of the string
            selectedOrderOptions = String(selectedOrderOptions.dropLast(2))
        }
        
        menuItem.selectedOptions = selectedOrderOptions
        menuItem.selectedQuantity = Int(quantityLabel.text!)!
        menuItem.specialInstructions = specialInstructionsTextField.text ?? ""
        menuItem.finalPrice = (Double(menuItem.selectedQuantity) * (menuItem.price + totalAddedPrice))
        Cart.restaurant = restaurant
        Cart.addItem(menuItem)
        
        Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { _ in
            self.dismiss(animated: true) {
                self.delegate?.itemAddedToCart()
            }
        }
    }
}

extension MenuItemViewController: UIScrollViewDelegate {
    
    enum TrackingPoint {
        case top
        case bottom
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topBarBottom = topBar.frame.origin.y + topBar.frame.height + ios13padding
        let topBarAlpha = calculateAlpha(trackingView: menuItemTitle, forScrollOffset: topBarBottom, padding: 16)
        topBarBackground.alpha = topBarAlpha
        topBarShadow.alpha = topBarAlpha
        
        menuItemTopBarTitle.alpha = calculateAlpha(trackingView: menuItemTitle, trackingPoint: .bottom, forScrollOffset: topBarBottom, padding: 8, transitionRange: 2)
    }
    
    // trackingView: the view that, when scrolled past the offset, will cause return alpha to be > 0
    // offset: the height from the top of the scrollview that, when trackingView is scrolled past,
    //         will cause return alpha to be > 0
    // padding: if a positive value is passed here, the appearing view will start appearing earlier.
    //          if negative, later
    // transitionRange: the bigger this number, the more the trackingView needs to scroll past the offset before alpha becomes 1.
    private func calculateAlpha(trackingView: UIView, trackingPoint tpPref: TrackingPoint = .top, forScrollOffset offset: CGFloat, padding: CGFloat = 0, transitionRange: CGFloat = 30) -> CGFloat {
        
        let trackingFrame = trackingView.convert(trackingView.bounds, to: nil)
        let trackingPoint = tpPref == .top ? trackingFrame.origin.y : trackingFrame.origin.y + trackingFrame.height
//        DDLogDebug("trackingPoint: \(trackingPoint), offset: \(offset + padding)")
        let offsetAndPadding = offset + padding
        
        if trackingPoint > offsetAndPadding { return 0 }
        if trackingPoint < offsetAndPadding - transitionRange { return 1 }
        
        let alpha = -trackingPoint.normalize(min: offsetAndPadding, max: offsetAndPadding + transitionRange)
        
        return alpha
    }
}
