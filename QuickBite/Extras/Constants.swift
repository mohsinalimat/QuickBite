//
//  Constants.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/14/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation

struct UDKeys {
    static let cartItems = "CART_ITEMS"
    static let cartRestaurantName = "CART_RESTAURANT_NAME"
    
    static let currentUser = "CURRENT_USER"
}

extension Notification.Name {
    static let userCancelledLogin = Notification.Name("USER_CANCELLED_LOGIN")
}
