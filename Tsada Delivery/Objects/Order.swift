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
import CoreLocation

enum OrderProgressStage: Int {
    case orderSubmitted
    case beingPreparedByStore
    case onItsWay
    case delivered
}

// Has to be a class because isDefault is mutable
class Order: Codable {
    let id: UUID
    
    // Customer Info
    var customerName: String
    var customerContactNumber: String
    var deliveryAddress: Address
    
    // Restaurant Info
    var restaurantName: String
    var restaurantAddress: String
    var restaurantContactNumber: String
    var restaurantImageUrl: String
    
    // Order Info
    var datePlaced: Date
    var lastUpdated: Date
    var items: [MenuItem]
    var total: Double
    var deliveryTimeEstimate: Int
    var paymentMethod: String
    var currentStage: Int
    
    var dictionary: [String : Any] {
        DDLogDebug("itemsDictionary count: \(itemsDictionary.count)")
        return [
            "id": id.uuidString,
            "customerName": customerName,
            "customerContactNumber": customerContactNumber,
            "datePlaced": Timestamp(date: datePlaced),
            "lastUpdated": Timestamp(date: lastUpdated),
            "deliveryAddress": deliveryAddress.dictionary,
            "restaurantName": restaurantName,
            "restaurantAddress": restaurantAddress,
            "restaurantContactNumber": restaurantContactNumber,
            "restaurantImageUrl": restaurantImageUrl,
            "items": itemsDictionary,
            "deliveryTimeEstimate": deliveryTimeEstimate,
            "paymentMethod": paymentMethod,
            "total": total,
            "currentStage": currentStage
        ]
    }
    
    var itemsDictionary: Array<[String : Any]> {
        return items.compactMap({ $0.orderDictionary })
    }

    init(id: UUID = UUID(),
         customerName: String,
         customerContactNumber: String,
         deliveryAddress: Address,
         restaurantName: String,
         restaurantAddress: String,
         restaurantContactNumber: String,
         restaurantImageUrl: String,
         datePlaced: Date,
         lastUpdated: Date,
         items: [MenuItem],
         total: Double,
         deliveryTimeEstimate: Int,
         paymentMethod: String,
         currentStage: OrderProgressStage) {
        self.id = id
        
        self.customerName = customerName
        self.customerContactNumber = customerContactNumber
        self.deliveryAddress = deliveryAddress
        
        self.restaurantName = restaurantName
        self.restaurantAddress = restaurantAddress
        self.restaurantContactNumber = restaurantContactNumber
        self.restaurantImageUrl = restaurantImageUrl
        
        self.datePlaced = datePlaced
        self.lastUpdated = lastUpdated
        self.items = items
        self.total = total
        self.deliveryTimeEstimate = deliveryTimeEstimate
        self.paymentMethod = paymentMethod
        self.currentStage = currentStage.rawValue
    }
    
    convenience init?(dictionary: [String : Any]) {
        guard let id                    = dictionary["id"] as? String,
            let customerName            = dictionary["customerName"] as? String,
            let customerContactNumber   = dictionary["customerContactNumber"] as? String,
            let deliveryAddressDict     = dictionary["deliveryAddress"] as? [String : Any],
            let datePlacedTimestamp     = dictionary["datePlaced"] as? Timestamp,
            let lastUpdatedTimestamp    = dictionary["lastUpdated"] as? Timestamp,
            let items                   = dictionary["items"] as? Array<[String : Any]>,
            let restaurantName          = dictionary["restaurantName"] as? String,
            let restaurantAddress       = dictionary["restaurantAddress"] as? String,
            let restaurantContactNumber = dictionary["restaurantContactNumber"] as? String,
            let restaurantImageUrl      = dictionary["restaurantImageUrl"] as? String,
            let total                   = dictionary["total"] as? Double,
            let paymentMethod           = dictionary["paymentMethod"] as? String,
            let currentStage            = dictionary["currentStage"] as? Int else {
                DDLogError("Unable to parse Order object: \(dictionary)")
                return nil
        }
        
        DDLogDebug("items count: \(items.count)")

        self.init(id: UUID(uuidString: id)!,
                  customerName: customerName,
                  customerContactNumber: customerContactNumber,
                  deliveryAddress: Address(dictionary: deliveryAddressDict)!,
                  restaurantName: restaurantName,
                  restaurantAddress: restaurantAddress,
                  restaurantContactNumber: restaurantContactNumber,
                  restaurantImageUrl: restaurantImageUrl,
                  datePlaced: datePlacedTimestamp.dateValue(),
                  lastUpdated: lastUpdatedTimestamp.dateValue(),
                  items: items.compactMap({ MenuItem(dictionary: $0) }),
                  total: total,
                  deliveryTimeEstimate: 0,
                  paymentMethod: paymentMethod,
                  currentStage: OrderProgressStage(rawValue: currentStage)!)
    }
}
