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
import CoreLocation

class Restaurant: Codable {
    var id: String
    var name: String
    var categories: String
    var contactNumber: String
    var alternativeContactNumber: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var rating: Double
    var openHours: String
    var address: String
    var topPick: Bool
    var imageUrl: String
    var menuItems: [MenuItem]
    
    var geoPoint: GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
    
    var distanceTime: DistanceTime? // Used for sorting purposes
    
    init(id: String,
         name: String,
         categories: String,
         contactNumber: String,
         alternativeContactNumber: String,
         latitude: CLLocationDegrees,
         longitude: CLLocationDegrees,
         rating: Double,
         openHours: String,
         address: String,
         topPick: Bool,
         imageUrl: String,
         menuItems: [MenuItem]) {
        self.id = id
        self.name = name
        self.categories = categories
        self.contactNumber = contactNumber
        self.alternativeContactNumber = alternativeContactNumber
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.openHours = openHours
        self.address = address
        self.topPick = topPick
        self.imageUrl = imageUrl
        self.menuItems = menuItems
    }

    convenience init?(dictionary: [String : Any]) {
        guard let id            = dictionary["id"] as? String,
            let name            = dictionary["name"] as? String,
            let categories      = dictionary["categories"] as? String,
            let contactNumber   = dictionary["contactNumber"] as? String,
            let geoPoint        = dictionary["geoPoint"] as? GeoPoint,
            let openHours       = dictionary["openHours"] as? String,
            let topPick         = dictionary["topPick"] as? Bool,
            let imageUrl        = dictionary["imageUrl"] as? String,
            let address         = dictionary["address"] as? String,
            let rating          = dictionary["rating"] as? Double,
            let menuItems       = dictionary["menuItems"] as? Array<[String : Any]> else { return nil }
        
        let alternativeContactNumber = dictionary["alternativeContactNumber"] as? String
        
        self.init(id: id,
                  name: name,
                  categories: categories,
                  contactNumber: contactNumber,
                  alternativeContactNumber: alternativeContactNumber ?? "",
                  latitude: CLLocationDegrees(geoPoint.latitude),
                  longitude: CLLocationDegrees(geoPoint.longitude),
                  rating: rating,
                  openHours: openHours,
                  address: address,
                  topPick: topPick,
                  imageUrl: imageUrl,
                  menuItems: menuItems.compactMap({ MenuItem(dictionary: $0) }))
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
