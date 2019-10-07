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
    var restaurantImageUrl: String
    
    // Order Info
    var datePlaced: Date
    var items: [MenuItem]
    var total: Double
    var paymentMethod: String
    var isPendingCompletion: Bool
    
    var dictionary: [String : Any] {
        return [
            "id": id.uuidString,
            "customerName": customerName,
            "customerContactNumber": customerContactNumber,
            "datePlaced": Timestamp(date: datePlaced),
            "deliveryAddress": deliveryAddress,
            "restaurantName": restaurantName,
            "restaurantAddress": restaurantAddress,
            "restaurantContactNumber": restaurantContactNumber,
            "restaurantImageUrl": restaurantImageUrl,
            "items": itemsDictionary,
            "paymentMethod": paymentMethod,
            "total": total,
            "isPendingCompletion": isPendingCompletion
        ]
    }
    
    var itemsDictionary: Array<[String : Any]> {
        return items.compactMap({ $0.orderDictionary })
    }

    init(id: UUID = UUID(),
         customerName: String,
         customerContactNumber: String,
         deliveryAddress: String,
         restaurantName: String,
         restaurantAddress: String,
         restaurantContactNumber: String,
         restaurantImageUrl: String,
         datePlaced: Date,
         items: [MenuItem],
         total: Double,
         paymentMethod: String,
         isPendingCompletion: Bool) {
        self.id = id
        
        self.customerName = customerName
        self.customerContactNumber = customerContactNumber
        self.deliveryAddress = deliveryAddress
        
        self.restaurantName = restaurantName
        self.restaurantAddress = restaurantAddress
        self.restaurantContactNumber = restaurantContactNumber
        self.restaurantImageUrl = restaurantImageUrl
        
        self.datePlaced = datePlaced
        self.items = items
        self.total = total
        self.paymentMethod = paymentMethod
        self.isPendingCompletion = isPendingCompletion
    }
    
    convenience init?(dictionary: [String : Any]) {
        guard let id                    = dictionary["id"] as? String,
            let customerName            = dictionary["customerName"] as? String,
            let customerContactNumber   = dictionary["customerContactNumber"] as? String,
            let deliveryAddress         = dictionary["deliveryAddress"] as? String,
            let datePlacedTimestamp     = dictionary["datePlaced"] as? Timestamp,
            let items                   = dictionary["items"] as? Array<[String : Any]>,
            let restaurantName          = dictionary["restaurantName"] as? String,
            let restaurantAddress       = dictionary["restaurantAddress"] as? String,
            let restaurantContactNumber = dictionary["restaurantContactNumber"] as? String,
            let restaurantImageUrl      = dictionary["restaurantImageUrl"] as? String,
            let total                   = dictionary["total"] as? Double,
            let paymentMethod           = dictionary["paymentMethod"] as? String,
            let isPendingCompletion     = dictionary["isPendingCompletion"] as? Bool else {
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
                  restaurantImageUrl: restaurantImageUrl,
                  datePlaced: datePlacedTimestamp.dateValue(),
                  items: items.compactMap({ MenuItem(dictionary: $0) }),
                  total: total,
                  paymentMethod: paymentMethod,
                  isPendingCompletion: isPendingCompletion)
    }
    
}
