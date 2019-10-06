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
            return nil
        }
    }
    
    static var paymentMethod: PaymentMethod?
    
    static var totalPrice: Double {
        return items.reduce(0) { (result, next) -> Double in
            return result + next.finalPrice
        }
    }
    
    static var totalQuantity: Int {
        return items.reduce(0) { (result, next) -> Int in
            return result + next.selectedQuantity
        }
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
        var cartItems = items
        
        // Merge identical items
        var itemIsUnique = true
        cartItems.forEach { (menuItem) in
            if item.equals(menuItem) {
                menuItem.selectedQuantity += item.selectedQuantity
                menuItem.finalPrice += item.finalPrice
                itemIsUnique = false
            }
        }
        
        if itemIsUnique {
            cartItems.append(item)
        }
        
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
