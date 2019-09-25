//
//  Restaurant.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/16/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//
//
// Restaurant "Chicka Loca!"
// |
// L__ MenuItem ("Wings")
//     |
//     L__ MenuOptionCategory ("Sides")
//     |   |
//     |   L__ [String] ("Side1", "Side2", etc.)
//     |
//     L__ MenuOptionCategory ("Extras")



import Foundation
import Firebase
import CocoaLumberjack

struct Restaurant: Codable {
    var name: String
    var categories: String
    var contactNumber: String
    var alternativeContactNumber: String
    var rating: Double
    var openHours: String
    var address: String
    var topPick: Bool
    var imageURL: String
    var menuItems: [MenuItem]
    
//    var dictionary: [String : Any] {
//        return [
//            "name": name,
//            "categories": categories,
//            "address": address,
//            "rating": rating
//        ]
//    }
}

extension Restaurant {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let categories = dictionary["categories"] as? String,
            let contactNumber = dictionary["contact_number"] as? String,
            let openHours = dictionary["open_hours"] as? String,
            let topPick = dictionary["top_pick"] as? Bool,
            let imageURL = dictionary["image_url"] as? String,
            let rating = dictionary["rating"] as? Double,
            let menuItems = dictionary["menu_items"] as? Array<[String : Any]> else { return nil }
        
        let alternativeContactNumber = dictionary["alternative_contact_number"] as? String
        
        self.init(name: name,
                  categories: categories,
                  contactNumber: contactNumber,
                  alternativeContactNumber: alternativeContactNumber ?? "",
                  rating: rating,
                  openHours: openHours,
                  address: "",
                  topPick: topPick,
                  imageURL: imageURL,
                  menuItems: FBSerializer.serializeMenuItems(menuItems))
    }
    
    func getFeaturedItems() -> [MenuItem] {
        return menuItems.filter { $0.featured }
    }
    
    func getMenuCategories() -> [String] {
        var categories: [String] = []
        for menuItem in menuItems {
            if !categories.contains(menuItem.category) {
                categories.append(menuItem.category)
            }
        }
        return categories
    }
    
    func getItemsInCategory(_ category: String) -> [MenuItem] {
        return menuItems.filter{ $0.category == category }
    }
}
