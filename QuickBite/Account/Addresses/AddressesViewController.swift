//
//  AddressesViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/30/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class AddressesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var addressesTableView: UITableView!
    
    var settingsMode = false
    
    private var addresses: [Address]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addressesTableView.rowHeight = UITableView.automaticDimension
        addressesTableView.estimatedRowHeight = 60
        
        if !settingsMode {
            navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(self, action: #selector(close), imageName: "close")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        addresses = UserUtil.currentUser!.addresses
        DispatchQueue.main.async {
            self.addressesTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if settingsMode {
            UserUtil.triggerUserSync(property: .addresses)
        }
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addNewAddressVC = storyboard.instantiateViewController(withIdentifier: "AddNewAddressSearchVC")
        navigationController?.pushViewController(addNewAddressVC, animated: true)
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressTableViewCell

        let address = addresses[indexPath.row]
        
        cell.setup(address, settingsMode: settingsMode)
        
        if (settingsMode && address.isDefault) || (!settingsMode && address.isSelected) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = addresses[indexPath.row]
        if settingsMode {
            guard !address.isDefault else { return }
            UserUtil.setDefaultAddress(addressId: address.id)
        } else {
            guard !address.isSelected else { return }
            UserUtil.setSelectedAddress(addressId: address.id)
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
