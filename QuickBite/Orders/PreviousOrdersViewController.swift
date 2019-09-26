//
//  PastOrdersTableViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/25/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CocoaLumberjack

class PreviousOrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var previousOrdersTableView: UITableView!
    @IBOutlet weak var largeTitleContainerViewHeight: NSLayoutConstraint!
    
    private var previousOrders: [Order]!
    private let dateFormatter = DateFormatter()
    
    var showBigTitle = true

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        
        previousOrders = UserUtil.currentUser!.pastOrders
        if previousOrders.isEmpty {
            previousOrdersTableView.alpha = 0
            previousOrdersTableView.isUserInteractionEnabled = false
        }
    }
    
    private func setupTitle() {
        if showBigTitle {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.title = "Previous Orders"
            largeTitleContainerViewHeight.constant = 0
        }
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousOrderTableViewCell", for: indexPath) as! PreviousOrderTableViewCell
        
        let order = previousOrders[indexPath.row]
        if order.restaurantImageUrl.isNotEmpty {
            cell.restaurantImage.sd_setImage(with: URL(string: order.restaurantImageUrl))
        } else {
            cell.restaurantImageWidthConstraint.constant = 0
        }
        cell.restaurantName.text = order.restaurantName
        cell.date.text = dateFormatter.string(from: order.datePlaced)
        cell.total.text = order.total.asPriceString
        cell.setMenuItems(order.items)
        
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
