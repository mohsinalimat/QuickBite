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
        
        // 2. Set the cart's restaurant name
        setRestaurantName(item.restaurantName)
        
        // 3. Add the MenuItem object to it
        cartItems.append(item)
        
        // 4. Encode the array and store it again
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
        if cartItems.isEmpty {
            UserDefaults.standard.removeObject(forKey: UDKeys.cartRestaurantName)
        }
        let newCartItemsData = try! JSONEncoder().encode(cartItems)
        UserDefaults.standard.set(newCartItemsData, forKey: UDKeys.cartItems)
    }
    
    static func removeAll() {
        UserDefaults.standard.removeObject(forKey: UDKeys.cartRestaurantName)
        let freshCart: [MenuItem] = []
        let freshCartData = try! JSONEncoder().encode(freshCart)
        UserDefaults.standard.set(freshCartData, forKey: UDKeys.cartItems)
    }
    
    static func setRestaurantName(_ name: String) {
        UserDefaults.standard.set(name, forKey: UDKeys.cartRestaurantName)
    }
    
    static func getRestaurantName() -> String {
        if let name = UserDefaults.standard.string(forKey: UDKeys.cartRestaurantName) {
            return name
        }
        DDLogError("Tried to get restaurant name without a restaurant name being set")
        return ""
    }
}
