//
//  UserUtil.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/18/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation

struct UserUtil {
//    static func
}

struct User: Codable {
    var name: String
    var phone: String
    var addresses: [Address]
}

extension User {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        
        let phone = dictionary["phone"] as? String ?? ""
        let addressesRaw = dictionary["addresses"] as? Array<[String : Any]> ?? []
        
        
        self.init(name: name,
                  phone: phone,
                  addresses: [])
    }
}
