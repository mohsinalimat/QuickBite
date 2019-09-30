//
//  UserUtil.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/18/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CocoaLumberjack

enum SyncProperty: String {
    case name = "name"
    case phone = "phone"
    case addresses = "addresses"
    case pastOrders = "past_orders"
    case pushNotifications = "push_notifications_enabled"
    case smsNotifications = "sms_notifications_enabled"
}

struct UserUtil {
    static private let dbUsers = Firestore.firestore().collection("users")
    
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
    
    // MARK: - Name
    static func setName(_ name: String) {
        guard let user = currentUser, user.name != name else {
            return
        }
        user.name = name
        updateCurrentUser(user)
        syncUserProperty(property: .name)
    }
    
    // MARK: - Phone
    static func setPhoneNumber(_ number: String) {
        guard let user = currentUser, user.phone != number else {
            return
        }
        user.phone = number
        updateCurrentUser(user)
        syncUserProperty(property: .phone)
    }
    
    // MARK: - Order
    static func addCurrentOrder(_ order: Order) {
        guard let user = currentUser else {
            return
        }
        user.currentOrder = order
        updateCurrentUser(user)
    }
    
    static func moveCurrentOrderToPreviousOrders() {
        guard let user = currentUser, let currentOrder = user.currentOrder else {
            DDLogError("failed moving current order to previous order")
            return
        }
        user.pastOrders.append(currentOrder)
        user.currentOrder = nil
        updateCurrentUser(user)
        syncUserProperty(property: .pastOrders)
    }
    
    // MARK: - Address
    static func addAddress(_ newAddress: Address) {
        guard let user = currentUser else {
            DDLogError("Tried to add address without a user set!")
            return
        }
        
        let existingAddresses = user.addresses
        
        // If new address has isDefault == true, set all others false
        if newAddress.isDefault {
            existingAddresses.forEach({ $0.isDefault = false })
        }
        
        // If new address has isSelected == true, set all others false
        if newAddress.isSelected {
            existingAddresses.forEach({ $0.isSelected = false })
        }
        

        user.addresses.append(newAddress)
        updateCurrentUser(user)
        syncUserProperty(property: .addresses)
    }
    
    static func setDefaultAddress(addressId: String) {
        guard let user = currentUser else {
            DDLogError("Tried to add address without a user set!")
            return
        }
        user.addresses.forEach({ $0.isDefault = $0.id == addressId })
        updateCurrentUser(user)
    }
    
    static func setSelectedAddress(addressId: String) {
        guard let user = currentUser else {
            DDLogError("Tried to add address without a user set!")
            return
        }
        user.addresses.forEach({ $0.isSelected = $0.id == addressId })
        updateCurrentUser(user)
    }
    
    static func setPushNotificationEnabled(_ enabled: Bool) {
        guard let user = currentUser else {
            DDLogError("No User!!")
            return
        }
        
        guard user.pushNotificationsEnabled != enabled else {
            return
        }
        
        user.pushNotificationsEnabled = enabled
        updateCurrentUser(user)
        syncUserProperty(property: .pushNotifications)
    }
    
    static func setSmsNotificationEnabled(_ enabled: Bool) {
        guard let user = currentUser else {
            DDLogError("No User!!")
            return
        }
        
        guard user.smsNotificationsEnabled != enabled else {
            return
        }
        
        user.smsNotificationsEnabled = enabled
        updateCurrentUser(user)
        syncUserProperty(property: .smsNotifications)
    }
    
    // MARK: - Sync
    // User this for manually triggering sync in situations where syncing
    // after every change would be excessive, i.e. changing default address
    static func triggerUserSync(property: SyncProperty) {
        syncUserProperty(property: property)
    }
    
    private static func syncUserProperty(property: SyncProperty) {
        // Sync addresses if the user is not using a guest account
        guard let fbUser = Auth.auth().currentUser, let user = currentUser else { return }
        DDLogDebug("Syncing userProperty: \(property.rawValue)")

        var newValue: Any!
        switch property {
        case .name:
            newValue = user.name
        case .phone:
            newValue = user.phone
        case .addresses:
            newValue = user.addresses.compactMap({ $0.dictionary })
        case .pastOrders:
            newValue = user.pastOrders.compactMap({ $0.dictionary })
        case .pushNotifications:
            newValue = user.pushNotificationsEnabled
        case .smsNotifications:
            newValue = user.smsNotificationsEnabled
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
    var pushNotificationsEnabled: Bool
    var smsNotificationsEnabled: Bool
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
    
    init(name: String = "",
         phone: String = "",
         addresses: [Address] = [],
         pastOrders: [Order] = [],
         pushNotificationsEnabled: Bool = true,
         smsNotificationsEnabled: Bool = true,
         isGuest: Bool) {
        self.name = name
        self.phone = phone
        self.addresses = addresses
        self.pastOrders = pastOrders
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.smsNotificationsEnabled = smsNotificationsEnabled
        self.isGuest = isGuest
    }
    
    convenience init(dictionary: [String : Any]) {
        let name = dictionary[SyncProperty.name.rawValue] as? String ?? ""
        let phone = dictionary[SyncProperty.phone.rawValue] as? String ?? ""
        let addresses = dictionary[SyncProperty.addresses.rawValue] as? Array<[String : Any]> ?? []
        let pastOrders = dictionary[SyncProperty.pastOrders.rawValue] as? Array<[String : Any]> ?? []
        let pushNotificationsEnabled = dictionary[SyncProperty.pushNotifications.rawValue] as? Bool ?? true
        let smsNotificationsEnabled = dictionary[SyncProperty.smsNotifications.rawValue] as? Bool ?? true
        
        self.init(name: name,
                  phone: phone,
                  addresses: addresses.compactMap({ Address(dictionary: $0) }),
                  pastOrders: pastOrders.compactMap({ Order(dictionary: $0) }),
                  pushNotificationsEnabled: pushNotificationsEnabled,
                  smsNotificationsEnabled: smsNotificationsEnabled,
                  isGuest: false)
    }
}
