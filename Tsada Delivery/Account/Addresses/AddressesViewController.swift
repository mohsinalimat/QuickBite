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
            navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(self, action: #selector(closeSelf), imageName: "close")
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
    
    private func selectAddress(_ index: Int) {
        let selectedAddress = addresses[index]
        guard !selectedAddress.isSelected else { return }
        addresses.forEach { $0.isSelected = $0.id == selectedAddress.id }
        UserUtil.setSelectedAddress(addressId: selectedAddress.id)
        addressesTableView.reloadData()
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAddress(indexPath.row)
    }
    
    // Disable deleting if there's only 1 address
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return settingsMode && tableView.numberOfRows(inSection: indexPath.section) > 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let addressToBeDeleted = addresses[indexPath.row]
            UserUtil.removeAddress(addressId: addressToBeDeleted.id)
            addresses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            if addressToBeDeleted.isSelected {
                selectAddress(0)
            }
        }
    }
}
