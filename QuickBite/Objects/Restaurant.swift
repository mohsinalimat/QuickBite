//
//  Restaurant.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/16/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import Firebase

struct Restaurant {
    var name: String
    var categories: String
    var rating: Double
    var openHours: String
    var address: String
    var topPick: Bool
    var imageURL: String
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "categories": categories,
            "address": address,
            "rating": rating
        ]
    }
}

extension Restaurant {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let categories = dictionary["categories"] as? String,
            let openHours = dictionary["open_hours"] as? String,
            let topPick = dictionary["top_pick"] as? Bool,
            let imageURL = dictionary["image_url"] as? String,
            let rating = dictionary["rating"] as? Double else { return nil }
        
        self.init(name: name,
                  categories: categories,
                  rating: rating,
                  openHours: openHours,
                  address: "",
                  topPick: topPick,
                  imageURL: imageURL)
    }
}
