//
//  PastOrdersTableViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/25/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class PastOrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var largeTitleContainerView: UIView!
    @IBOutlet weak var pastOrdersTableView: UITableView!
    
    var showBigTitle = true

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
    }
    
    private func setupTitle() {
        if showBigTitle {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            pastOrdersTableView.contentInset.top = largeTitleContainerView.frame.height
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.title = "Past Orders"
            largeTitleContainerView.removeFromSuperview()
        }
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
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
