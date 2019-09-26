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
        case pastOrders = "past_orders"
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
    
    static func addCurrentOrder(_ order: Order) {
        guard let user = currentUser else {
            return
        }
        user.currentOrder = order
        updateCurrentUser(user)
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
    
    static func addPastOrder(_ order: Order) {
        guard let user = currentUser else {
            DDLogError("Tried to add past order without a user set!")
            return
        }
        
        user.pastOrders.append(order)
        updateCurrentUser(user)
        syncUserProperty(property: .pastOrders)
    }
    
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
            newValue = user.addresses.compactMap({ $0.dictionary })
        case .pastOrders:
            newValue = user.pastOrders.compactMap({ $0.dictionary })
        }
        

        dbUsers.document(fbUser.uid).updateData([
            property.rawValue: newValue!
        ]) { err in
            if let err = err {
                DDLogError("Error syncing property: \(err)")
            }
        }
    }
}

class User: Codable {
    var name: String
    var phone: String
    var addresses: [Address]
    var currentOrder: Order?
    var pastOrders: [Order]
    var isGuest: Bool
    
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
    
    init(name: String = "", phone: String = "", addresses: [Address] = [], pastOrders: [Order] = [], isGuest: Bool) {
        self.name = name
        self.phone = phone
        self.addresses = addresses
        self.pastOrders = pastOrders
        self.isGuest = isGuest
    }
    
    convenience init(dictionary: [String : Any]) {
        let name = dictionary["name"] as? String ?? ""
        let phone = dictionary["phone"] as? String ?? ""
        let addresses = dictionary["addresses"] as? Array<[String : Any]> ?? []
        let pastOrders = dictionary["past_orders"] as? Array<[String : Any]> ?? []
        
        self.init(name: name,
                  phone: phone,
                  addresses: addresses.compactMap({ Address(dictionary: $0) }),
                  pastOrders: pastOrders.compactMap({ Order(dictionary: $0) }),
                  isGuest: false)
    }
}
