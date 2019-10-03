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
            "item_name": itemName,
            "final_price": finalPrice,
            "selected_quantity": selectedQuantity,
            "selected_options": selectedOptions,
            "special_instructions": specialInstructions
        ]
    }
    
    init(itemName: String,
         description: String,
         price: Double,
         category: String,
         featured: Bool,
         imageUrl: String,
         itemOptionCategories: [MenuItemOptionCategory]) {
        self.itemName = itemName
        self.description = description
        self.price = price
        self.category = category
        self.featured = featured
        self.imageUrl = imageUrl
        self.itemOptionCategories = itemOptionCategories
        self.selectedOptions = ""
        self.selectedQuantity = 0
        self.finalPrice = 0
        self.specialInstructions = ""
    }
    
    convenience init?(dictionary: [String : Any]) {
        // Required fields
        guard let itemName              = dictionary["item_name"] as? String,
            let description             = dictionary["description"] as? String,
            let price                   = dictionary["price"] as? Double,
            let category                = dictionary["category"] as? String,
            let featured                = dictionary["featured"] as? Bool,
            let itemOptionCategories    = dictionary["item_option_categories"] as? Array<[String : Any]> else { return nil }
        
        // Optional fields
        let imageURL = dictionary["item_image_url"] as? String ?? ""
        
        self.init(itemName: itemName,
                  description: description,
                  price: price,
                  category: category,
                  featured: featured,
                  imageUrl: imageURL,
                  itemOptionCategories: itemOptionCategories.compactMap({ MenuItemOptionCategory(dictionary: $0) }))
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
        guard let categoryName      = dictionary["options_category_name"] as? String,
            let isSingleSelection   = dictionary["single_selection"] as? Bool,
            let isRequired          = dictionary["required"] as? Bool,
            let options             = dictionary["options"] as? Array<[String : Any]> else { return nil }
        
        // Convert options array into [String] array
        var optionsStringArray: [String] = []
        for option in options {
            if let name = option["option_name"] as? String,
                let price = option["added_price"] as? Double {
                let optionString = name + " ₱" + String(price)
                optionsStringArray.append(optionString)
            }
        }
        
        self.init(categoryName: categoryName,
                  options: optionsStringArray,
                  isSingleSelection: isSingleSelection,
                  isRequired: isRequired)
    }
}
