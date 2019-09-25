//
//  UserUtil.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/18/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import Firebase
import CocoaLumberjack

struct UserUtil {
    static private let dbUsers = Firestore.firestore().collection("users")
    
    enum SyncProperty: String {
        case name = "name"
        case phone = "phone"
        case address = "address"
    }
    
    static var currentUser: User? {
        if let currentUserData = UserDefaults.standard.data(forKey: UDKeys.currentUser) {
            return try! JSONDecoder().decode(User.self, from: currentUserData)
        }
        return nil
    }
    
    static func updateCurrentUser(_ user: User) {
        let userData = try! JSONEncoder().encode(user)
        UserDefaults.standard.set(userData, forKey: UDKeys.currentUser)
    }
    
    static func clearCurrentUser() {
        DDLogDebug("Clearing current user!")
        UserDefaults.standard.removeObject(forKey: UDKeys.currentUser)
    }
    
    static func setName(_ name: String) {
        guard let user = currentUser, user.name != name else {
            return
        }
        user.name = name
        updateCurrentUser(user)
        syncUserProperty(property: .name)
    }
    
    static func setPhoneNumber(_ number: String) {
        guard let user = currentUser, user.phone != number else {
            return
        }
        user.phone = number
        updateCurrentUser(user)
        syncUserProperty(property: .phone)
    }
    
    static func addAddress(_ address: Address) {
        guard let user = currentUser else {
            DDLogError("Tried to add address without a user set!")
            return
        }

        user.addresses.append(address)
        updateCurrentUser(user)
        syncUserProperty(property: .address)
    }
    
    //    static func setDefaultAddress(id: UUID) {
    //        let addresses = getAddresses()
    //        for address in addresses {
    //            address.isDefault = address.id == id
    //        }
    //        updateAddresses(addresses)
    //    }
    
    private static func syncUserProperty(property: SyncProperty) {
        DDLogDebug("Syncing userProperty: \(property.rawValue)")
        // Sync addresses if the user is not using a guest account
        guard let fbUser = Auth.auth().currentUser, let user = currentUser else { return }

        var newValue: Any!
        switch property {
        case .name:
            newValue = user.name
        case .phone:
            newValue = user.phone
        case .address:
            var serializedAddresses: [[String : Any]] = []
            for address in user.addresses {
                serializedAddresses.append(address.dictionary)
            }
            newValue = serializedAddresses
        }
        

        dbUsers.document(fbUser.uid).updateData([
            property.rawValue: newValue!
        ]) { err in
            if let err = err {
                DDLogError("Error syncing porperty: \(err)")
            }
        }
    }
}

class User: Codable {
    var name: String
    var phone: String
    var addresses: [Address]
    
    var defaultAddress: Address {
        guard !addresses.isEmpty else {
            fatalError("Tried to get default address with no addresses set")
        }
        
        if let defaultAddress = addresses.first(where: { $0.isDefault }) {
            return defaultAddress
        }
        
        return addresses[0]
    }
    
    // Returns default address if no address is selected
    var selectedAddress: Address {
        guard !addresses.isEmpty else {
            fatalError("Tried to get selected address with no addresses set")
        }
        
        if let selectedAddress = addresses.first(where: { $0.isSelected }) {
            return selectedAddress
        }
        
        return defaultAddress
    }
    
//    var dictionary: [String : Any] {
//        return [
//            "floor_dept_house_no": floorDeptHouseNo,
//            "street": street,
//            "barangay": barangay,
//            "building": building,
//            "landmark": landmark,
//            "is_default": isDefault
//        ]
//    }
    
    init(name: String = "", phone: String = "", addresses: [Address] = []) {
        self.name = name
        self.phone = phone
        self.addresses = addresses
    }
    
    convenience init(dictionary: [String : Any]) {
        let name = dictionary["name"] as? String ?? ""
        let phone = dictionary["phone"] as? String ?? ""
        let addressesRaw = dictionary["addresses"] as? Array<[String : Any]> ?? []
        
        var addresses: [Address] = []
        for addressRaw in addressesRaw {
            if let address = Address(dictionary: addressRaw) {
                addresses.append(address)
            }
        }
        
        self.init(name: name,
                  phone: phone,
                  addresses: addresses)
    }
}
