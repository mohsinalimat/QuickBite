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
    @IBOutlet weak var changeTotal: UILabel!
    
    var order: Order! // Set by presenting view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderTotal.text = order.total.asPriceString
        changeTotal.text = order.changeFor.asPriceString
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemTableViewCell
        
        let orderItem = order.items[indexPath.row]
        if orderItem.imageURL.isNotEmpty {
            cell.itemImage.sd_setImage(with: URL(string: orderItem.imageURL))
        } else {
            cell.imageWidthConstraint.constant = 0
        }
        cell.itemTitle.text = orderItem.itemName
        cell.selectedItemOptions.text = orderItem.selectedOptions
        cell.quantityLabel.text = "\(orderItem.selectedQuantity)x"
        cell.priceLabel.text = orderItem.finalPrice.asPriceString
        
        return cell
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
