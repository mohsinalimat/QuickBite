//
//  Cart.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/18/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import CocoaLumberjack

struct Cart {
    
    static var bannerIsShown = false
    
    static var hasItems: Bool {
        return items.count >= 1
    }
    
    static var restaurant: Restaurant? {
        set {
            let restaurantData = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.set(restaurantData, forKey: UDKeys.cartRestaurant)
        }
        get {
            if let restaurantData = UserDefaults.standard.data(forKey: UDKeys.cartRestaurant) {
                return try! JSONDecoder().decode(Restaurant.self, from: restaurantData)
            }
            DDLogError("Tried getting cart restaurant without a restaurant being set")
            return nil
        }
        
    }
    
    static var totalPrice: Double {
        var totalPrice = 0.0
        for item in items {
            totalPrice += item.finalPrice
        }
        return totalPrice
    }
    
    static var totalQuantity: Int {
        var totalQuantity = 0
        for item in items {
            totalQuantity += item.selectedQuantity
        }
        return totalQuantity
    }
    
    static var items: [MenuItem] {
        if let cartItemsData = UserDefaults.standard.data(forKey: UDKeys.cartItems) {
            let cartItems = try! JSONDecoder().decode([MenuItem].self, from: cartItemsData)
            return cartItems
        } else {
            return []
        }
    }
    
    static func addItem(_ item: MenuItem) {
        // 1. Get the current cart array
        var cartItems = items
        
        // 3. Add the MenuItem object to it
        cartItems.append(item)
        
        // 4. Encode the array and store it again
        let newCartItemsData = try! JSONEncoder().encode(cartItems)
        UserDefaults.standard.set(newCartItemsData, forKey: UDKeys.cartItems)
    }
    
    static func removeItem(at: Int) {
        var cartItems = items
        cartItems.remove(at: at)
        if cartItems.isEmpty {
            UserDefaults.standard.removeObject(forKey: UDKeys.cartRestaurant)
        }
        let newCartItemsData = try! JSONEncoder().encode(cartItems)
        UserDefaults.standard.set(newCartItemsData, forKey: UDKeys.cartItems)
    }
    
    static func empty() {
        UserDefaults.standard.removeObject(forKey: UDKeys.cartRestaurant)
        let freshCart: [MenuItem] = []
        let freshCartData = try! JSONEncoder().encode(freshCart)
        UserDefaults.standard.set(freshCartData, forKey: UDKeys.cartItems)
    }
}
