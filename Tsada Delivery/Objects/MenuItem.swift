//
//  MenuItem.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/16/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import CocoaLumberjack

class MenuItem: Codable {
    var itemName: String
    var description: String
    var price: Double
    var category: String
    var featured: Bool
    var imageUrl: String
    var itemOptionCategories: [MenuItemOptionCategory]
    
    // Properties used when the item is added to an order
    var selectedOptions: String
    var selectedQuantity: Int
    var finalPrice: Double
    var specialInstructions: String
    
    // USED FOR ORDERS ONLY
    var orderDictionary: [String : Any] {
        return [
            "itemName": itemName,
            "finalPrice": finalPrice,
            "selectedQuantity": selectedQuantity,
            "selectedOptions": selectedOptions,
            "specialInstructions": specialInstructions
        ]
    }
    
    init(itemName: String,
         description: String,
         price: Double,
         category: String,
         featured: Bool,
         imageUrl: String,
         itemOptionCategories: [MenuItemOptionCategory],
         selectedOptions: String,
         selectedQuantity: Int,
         finalPrice: Double,
         specialInstructions: String) {
        self.itemName = itemName
        self.description = description
        self.price = price
        self.category = category
        self.featured = featured
        self.imageUrl = imageUrl
        self.itemOptionCategories = itemOptionCategories
        self.selectedOptions = selectedOptions
        self.selectedQuantity = selectedQuantity
        self.finalPrice = finalPrice
        self.specialInstructions = specialInstructions
    }
    
    convenience init?(dictionary: [String : Any]) {
        // Required fields

        guard let itemName = dictionary["itemName"] as? String else {
            DDLogError("Dictionary: \(dictionary)")
            return nil
        }
        
        // Optional fields
        let category    = dictionary["category"] as? String ?? ""
        let featured    = dictionary["featured"] as? Bool ?? false
        let price       = dictionary["price"] as? Double ?? 0.0
        let description = dictionary["description"] as? String ?? ""
        let imageUrl    = dictionary["itemImageUrl"] as? String ?? ""
        let itemOptionCategories = dictionary["itemOptionCategories"] as? Array<[String : Any]> ?? []
        
        // Past Order Fields
        let finalPrice  = dictionary["finalPrice"] as? Double ?? 0.0
        let selectedOptions = dictionary["selectedOptions"] as? String ?? ""
        let selectedQuantity = dictionary["selectedQuantity"] as? Int ?? 1
        let specialInstructions = dictionary["specialInstructions"] as? String ?? ""
        
        self.init(itemName: itemName,
                  description: description,
                  price: price,
                  category: category,
                  featured: featured,
                  imageUrl: imageUrl,
                  itemOptionCategories: itemOptionCategories.compactMap({ MenuItemOptionCategory(dictionary: $0) }),
                  selectedOptions: selectedOptions,
                  selectedQuantity: selectedQuantity,
                  finalPrice: finalPrice,
                  specialInstructions: specialInstructions)
    }
    
    
    func equals(_ other: MenuItem) -> Bool {
        return self.itemName == other.itemName &&
            self.description == other.description &&
            self.selectedOptions == other.selectedOptions &&
            self.specialInstructions == other.specialInstructions
    }
}

struct MenuItemOptionCategory: Codable {
    var categoryName: String // e.g. "Sides", "Extras", etc...
    var options: [String]
    var isSingleSelection: Bool
    var isRequired: Bool
}

extension MenuItemOptionCategory {
    init?(dictionary: [String : Any]) {
        guard let categoryName      = dictionary["optionsCategoryName"] as? String,
            let isSingleSelection   = dictionary["singleSelection"] as? Bool,
            let isRequired          = dictionary["required"] as? Bool,
            let optionsRaw          = dictionary["options"] as? Array<[String : Any]> else { return nil }
        
        // Convert options array into [String] array
        let options: [String] = optionsRaw.compactMap({
            if let name = $0["optionName"] as? String, let price = $0["addedPrice"] as? Double {
                return name + " ₱" + String(price)
            }
            return nil
        })
        
        self.init(categoryName: categoryName,
                  options: options,
                  isSingleSelection: isSingleSelection,
                  isRequired: isRequired)
    }
}
