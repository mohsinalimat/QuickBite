//
//  Order.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/25/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Firebase

// Has to be a class because isDefault is mutable
class Order: Codable {
    let id: UUID
    
    // Customer Info
    var customerName: String
    var customerContactNumber: String
    var deliveryAddress: String
    
    // Restaurant Info
    var restaurantName: String
    var restaurantAddress: String
    var restaurantContactNumber: String
    
    // Order Info
    var datePlaced: Date
    var items: [MenuItem]
    var total: Double
    var isPendingCompletion: Bool
    
    var dictionary: [String : Any] {
        return [
            "id": id.uuidString,
            "customer_name": customerName,
            "customer_contact_number": customerContactNumber,
            "date_placed": Timestamp(date: datePlaced),
            "delivery_address": deliveryAddress,
            "restaurant_name": restaurantName,
            "restaurant_address": restaurantAddress,
            "restaurant_contact_number": restaurantContactNumber,
            "items": itemsDictionary,
            "total": total,
            "is_pending_completion": isPendingCompletion
        ]
    }
    
    var itemsDictionary: Array<[String : Any]> {
        var itemsDict: Array<[String : Any]> = []
        for item in items {
            itemsDict.append(item.orderDictionary)
        }
        return itemsDict
    }

    init(id: UUID = UUID(),
         customerName: String,
         customerContactNumber: String,
         deliveryAddress: String,
         restaurantName: String,
         restaurantAddress: String,
         restaurantContactNumber: String,
         datePlaced: Date,
         items: [MenuItem],
         total: Double,
         isPendingCompletion: Bool) {
        self.id = id
        
        self.customerName = customerName
        self.customerContactNumber = customerContactNumber
        self.deliveryAddress = deliveryAddress
        
        self.restaurantName = restaurantName
        self.restaurantAddress = restaurantAddress
        self.restaurantContactNumber = restaurantContactNumber
        
        
        self.datePlaced = datePlaced
        self.items = items
        self.total = total
        self.isPendingCompletion = isPendingCompletion
    }
    
    convenience init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
            let customerName = dictionary["customer_name"] as? String,
            let customerContactNumber = dictionary["customer_contact_number"] as? String,
            let deliveryAddress = dictionary["delivery_address"] as? String,
            let datePlacedTimestamp = dictionary["date_placed"] as? Timestamp,
            let items = dictionary["items"] as? Array<[String : Any]>,
            let restaurantName = dictionary["restaurant_name"] as? String,
            let restaurantAddress = dictionary["restaurant_address"] as? String,
            let restaurantContactNumber = dictionary["restaurant_contact_number"] as? String,
            let total = dictionary["order_total"] as? Double,
            let isPendingCompletion = dictionary["is_pending_completion"] as? Bool else {
                DDLogError("Unable to parse Order object: \(dictionary)")
                return nil
        }
        

        self.init(id: UUID(uuidString: id)!,
                  customerName: customerName,
                  customerContactNumber: customerContactNumber,
                  deliveryAddress: deliveryAddress,
                  restaurantName: restaurantName,
                  restaurantAddress: restaurantAddress,
                  restaurantContactNumber: restaurantContactNumber,
                  datePlaced: datePlacedTimestamp.dateValue(),
                  items: FBSerializer.serializeMenuItems(items),
                  total: total,
                  isPendingCompletion: isPendingCompletion)
    }
    
}
