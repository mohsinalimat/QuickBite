//
//  UserUtil.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/18/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import CocoaLumberjack

struct UserUtil {
    static var currentUser: User? {
        if let currentUserData = UserDefaults.standard.data(forKey: UDKeys.currentUser) {
            return try! JSONDecoder().decode(User.self, from: currentUserData)
        }
        return nil
    }
    
    static func setCurrentUser(_ user: User) {
        let userData = try! JSONEncoder().encode(user)
        UserDefaults.standard.set(userData, forKey: UDKeys.currentUser)
    }
    
    static func clearCurrentUser() {
        UserDefaults.standard.removeObject(forKey: UDKeys.currentUser)
    }
    
    static func setName(_ name: String) {
        if let user = currentUser {
            user.name = name
            setCurrentUser(user)
        } else {
            DDLogError("Tried setting currentUser name without a currentUser set")
        }
    }
    
    static func setPhoneNumber(_ number: String) {
        if let user = currentUser {
            user.phone = number
            setCurrentUser(user)
        } else {
            DDLogError("Tried setting currentUser name without a currentUser set")
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
    
    func getDefaultAddress() -> Address {
        guard !addresses.isEmpty else {
            fatalError("Tried to get default address with no addresses set")
        }
        
        if let defaultAddress = addresses.first(where: { $0.isDefault }) {
            return defaultAddress
        }
        
        return addresses[0]
    }
}
