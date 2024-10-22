//
//  CurrentOrderDetailViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/26/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class CurrentOrderDetailViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var orderItemsTableView: AutoSizedTableView!
    @IBOutlet weak var orderTotal: UILabel!
    @IBOutlet weak var paymentMethod: UILabel!
    
    var order: Order! // Set by presenting view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderTotal.text = order.total.asPriceString
        paymentMethod.text = order.paymentMethod
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemTableViewCell
        
        let orderItem = order.items[indexPath.row]
        if orderItem.imageUrl.isNotEmpty {
            cell.itemImage.sd_setImage(with: URL(string: orderItem.imageUrl), placeholderImage: UIImage(named: "tertiary_system_grouped_background"))
        } else {
            cell.itemImage.removeFromSuperview()
        }
        cell.itemTitle.text = orderItem.itemName
        cell.selectedItemOptions.text = orderItem.selectedOptions
        cell.specialInstructions.text = orderItem.specialInstructions
        cell.quantityLabel.text = "\(orderItem.selectedQuantity)x"
        cell.priceLabel.text = orderItem.finalPrice.asPriceString
        
        return cell
    }
}
