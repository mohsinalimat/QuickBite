//
//  MenuItemViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class MenuItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var orderOptionsTableView: UITableView!
    @IBOutlet weak var menuItemTitle: UILabel!
    @IBOutlet weak var menuItemDescription: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var topBar: GradientView!
    @IBOutlet weak var topBarShadow: GradientView!
    @IBOutlet weak var bottomFadeView: UIView!
    
    // Quantity Button
    @IBOutlet weak var decreaseQuantityBtn: UIButton!
    @IBOutlet weak var increaseQuantityBtn: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    
    var menuItem = MenuItem()
    
    private var totalExtrasPrice = 0 {
        didSet { updateTotalPriceLabel() }
    }
    private var topBarIsShown = false
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create some fake data for now
        let menuItemOption1 = MenuItemOption(name: "Sides",
                                             options: ["Strawberries", "Blueberries", "Honey", "Chocolate Chips"],
                                             isSingleSelection: true, isRequired: true)
        let menuItemOption2 = MenuItemOption(name: "Extras",
                                             options: ["Butter packet ₱30", "Chocolate Syrup", "Syrup ₱40"],
                                             isSingleSelection: false, isRequired: false)
        menuItem = MenuItem(name: "Brioche French Toast",
                            description: "Dipped in our signature cinnamon egg batter and served with your choice of Virginia ham, sizzling bacon or sausage along with two eggs any style.",
                            price: 139,
                            orderOptions: [menuItemOption1, menuItemOption2],
                            selectedOptions: "", selectedQuantity: 0)
    
        
        menuItemTitle.text = menuItem.name
        menuItemDescription.text = menuItem.description
        totalPriceLabel.text = menuItem.price.asPriceString
        
        orderOptionsTableView.register(OrderOptionHeaderView.nib, forHeaderFooterViewReuseIdentifier: OrderOptionHeaderView.reuseIdentifier)
        orderOptionsTableView.rowHeight = UITableView.automaticDimension
        orderOptionsTableView.estimatedRowHeight = 60
        
        bottomFadeView.fadeView(style: .top, percentage: 0.35)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderOptionHeaderView.reuseIdentifier) as! OrderOptionHeaderView
        if section == 0 {
            header.orderOptionsTitle.text = "Sides"
            header.isSingleSelection = true
            header.selectionIsRequired = true
        } else {
            header.orderOptionsTitle.text = "Extras"
            header.isSingleSelection = false
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItem.orderOptions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItem.orderOptions[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderOptionCell", for: indexPath) as! OrderOptionTableViewCell
        
        let orderOption = menuItem.orderOptions[indexPath.section]
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
        
        if header.isSingleSelection {
            // Deselect other rows in the same section
            for cellRow in 0..<tableView.numberOfRows(inSection: indexPath.section) {
                if cellRow != indexPath.row {
                    tableView.deselectRow(at: IndexPath(row: cellRow, section: indexPath.section), animated: true)
                }
            }
        }
        
        let orderOption = menuItem.orderOptions[indexPath.section]
        if let price = orderOption.options[indexPath.row].getPrice() {
            totalExtrasPrice += price
        }
    }
    
    // Prevent deselection for single selection sections
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let header = tableView.headerView(forSection: indexPath.section) as! OrderOptionHeaderView
        guard !header.isSingleSelection else { return nil }
        
        let orderOption = menuItem.orderOptions[indexPath.section]
        if let price = orderOption.options[indexPath.row].getPrice() {
            totalExtrasPrice -= price
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
        let quantity = Int(quantityLabel.text!)!
        totalPriceLabel.text = ((quantity * menuItem.price) + totalExtrasPrice).asPriceString
    }
    
    
    @IBAction func addToOrderTapped(_ addButton: UIButton) {
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
        menuItem.price = (menuItem.selectedQuantity * menuItem.price) + totalExtrasPrice
        Cart.addItem(menuItem)
        
        Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension MenuItemViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if shouldShowTopBar != topBarIsShown {
            UIView.animate(withDuration: 0.1) {
                self.topBar.backgroundColor = self.topBarIsShown ? UIColor.clear : UIColor.white
                self.topBarShadow.alpha = self.topBarIsShown ? 0.0 : 1.0
            }
            topBarIsShown = !topBarIsShown
        }
    }
    
    private var shouldShowTopBar: Bool {
        let frame = menuItemTitle.convert(menuItemTitle.bounds, to: nil)
        return (frame.origin.y - 8) < topBar.frame.height
    }
}
