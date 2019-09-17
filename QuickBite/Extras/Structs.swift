//
//  Cart.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/29/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import UIKit

struct Cart {
    
    static var bannerIsShown = false
    
    static var hasItems: Bool {
        return getItems().count >= 1
    }
    
    static var totalPrice: Double {
        var totalPrice = 0.0
        for item in getItems() {
            totalPrice += item.finalPrice
        }
        return totalPrice
    }
    
    static func addItem(_ item: MenuItem) {
        // 1. Get the current cart array
        var cartItems = getItems()
        
        // 2. Add the MenuItem object to it
        cartItems.append(item)
        
        // 3. Encode the array and store it again
        let newCartItemsData = try! JSONEncoder().encode(cartItems)
        UserDefaults.standard.set(newCartItemsData, forKey: UDKeys.cartItems)
    }
    
    static func getItems() -> [MenuItem] {
        if let cartItemsData = UserDefaults.standard.data(forKey: UDKeys.cartItems) {
            let cartItems = try! JSONDecoder().decode([MenuItem].self, from: cartItemsData)
            return cartItems
        } else {
            return []
        }
    }
    
    static func getTotalQuantity() -> Int {
        var totalQuantity = 0
        for item in getItems() {
            totalQuantity += item.selectedQuantity
        }
        return totalQuantity
    }
    
    static func removeItem(at: Int) {
        var cartItems = getItems()
        cartItems.remove(at: at)
        let newCartItemsData = try! JSONEncoder().encode(cartItems)
        UserDefaults.standard.set(newCartItemsData, forKey: UDKeys.cartItems)
    }
    
    static func removeAll() {
        let freshCart: [MenuItem] = []
        let freshCartData = try! JSONEncoder().encode(freshCart)
        UserDefaults.standard.set(freshCartData, forKey: UDKeys.cartItems)
    }
}

struct HighlightedRestaurantCategory {
    var categoryName = ""
    var restaurants: [Restaurant] = []
}

// Address
struct AddressBook {
    // These functions need to be abstracted so that the cart logic can use them as well
    static func addAddress(_ address: Address) {
        var addresses = getAddresses()
        
        addresses.append(address)
        
        let newAddressesData = try! JSONEncoder().encode(addresses)
        UserDefaults.standard.set(newAddressesData, forKey: UDKeys.addressBook)
    }
    
    static func getAddresses() -> [Address] {
        if let addressesData = UserDefaults.standard.data(forKey: UDKeys.addressBook) {
            let addresses = try! JSONDecoder().decode([Address].self, from: addressesData)
            return addresses
        } else {
            return []
        }
    }
    
    static func setDefaultAddress(id: UUID) {
        let addresses = getAddresses()
        for address in addresses {
            address.isDefault = address.id == id
        }
    }
    
    static func getDefaultAddress() -> Address {
        let addresses = getAddresses()
        guard addresses.count >= 1 else {
            fatalError("TRIED TO GET DEFAULT ADDRESS WHEN THERE ARE NO SAVED ADDRESSES")
        }
        
        for address in getAddresses() {
            if address.isDefault {
                return address
            }
        }
        
        return addresses[0]
    }
}

class Address: Codable {
    let id = UUID()
    var floorDeptHouseNo: String
    var street: String
    var barangay: String
    var building: String
    var landmark: String
    var isDefault: Bool
    
    init(floorDeptHouseNo: String, street: String, barangay: String, building: String, landmark: String, isDefault: Bool = false) {
        self.floorDeptHouseNo = floorDeptHouseNo
        self.street = street
        self.barangay = barangay
        self.building = building
        self.landmark = landmark
        self.isDefault = isDefault
    }
    
    func toString() -> String {
        let addressLines = [floorDeptHouseNo, street, barangay, building, landmark]
        var fullAddressString = ""
        for line in addressLines {
            if line.isNotEmpty {
                fullAddressString.append(line + ", ")
            }
        }
        return fullAddressString.chompLast(2)
    }
}
