//
//  Cart.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/29/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CocoaLumberjack

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
        syncAddresses()
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
    
    private static func syncAddresses() {
        DDLogDebug("Syncing addresses")
        // Sync addresses if the user is not using a guest account
        guard let user = Auth.auth().currentUser else { return }
        
        let addresses = AddressBook.getAddresses()
        var serializedAddresses: [[String : Any]] = []
        for address in addresses {
            serializedAddresses.append(address.dictionary)
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).updateData([
            "addresses": serializedAddresses
        ]) { err in
            if let err = err {
                DDLogError("Error updating address: \(err)")
            }
        }
    }
}

// Has to be a class because isDefault is mutable
class Address: Codable {
    let id: UUID
    var floorDeptHouseNo: String
    var street: String
    var barangay: String
    var building: String
    var landmark: String
    var isDefault: Bool
    
    var dictionary: [String : Any] {
        return [
            "floor_dept_house_no": floorDeptHouseNo,
            "street": street,
            "barangay": barangay,
            "building": building,
            "landmark": landmark,
            "is_default": isDefault
        ]
    }

    init(floorDeptHouseNo: String, street: String, barangay: String, building: String, landmark: String, isDefault: Bool = false) {
        self.id = UUID()
        self.floorDeptHouseNo = floorDeptHouseNo
        self.street = street
        self.barangay = barangay
        self.building = building
        self.landmark = landmark
        self.isDefault = isDefault
    }
    
    convenience init?(dictionary: [String : Any]) {
        guard let street = dictionary["street"] as? String else { return nil }

        let floorDeptHouseNo = dictionary["floor_dept_house_no"] as? String ?? ""
        let barangay = dictionary["barangay"] as? String ?? ""
        let building = dictionary["building"] as? String ?? ""
        let landmark = dictionary["landmark"] as? String ?? ""
        let isDefault = dictionary["is_default"] as? Bool ?? false

        self.init(floorDeptHouseNo: floorDeptHouseNo,
                  street: street,
                  barangay: barangay,
                  building: building,
                  landmark: landmark,
                  isDefault: isDefault)
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
