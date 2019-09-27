//
//  FirebaseDataWriterViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import Firebase
import CocoaLumberjack

class FirebaseDataWriterViewController: UIViewController {
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLogDebug("Writing restaurants")
        writeRestaurants()
    }
    
    private func writeRestaurants() {
        let restaurantRef = db.collection("restaurants")
        
        restaurantRef.document("chika_loca").setData([
            "name": "Chika Loca!",
            "categories": "Chicken, BBQ",
            "open_hours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
            "contact_number": "+631234567890",
            "alternative_contact_number": "+634238204728",
            "geo_point": GeoPoint(latitude: 8.476797, longitude: 124.645025),
            "rating": 3.5,
            "image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/food_sample_inasal.jpg?alt=media&token=70e75f54-b368-4c44-a4b7-5bda1caf5c53",
            "address": "",
            "top_pick": true,
            "menu_items": [
                [
                    "item_name": "5pc. BBQ Chicken Wings",
                    "description": "",
                    "category": "Chicken",
                    "featured": true,
                    "item_image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/sample_food_3.jpg?alt=media&token=2eb2b213-df11-45cf-8867-66785d9f8075",
                    "price": 110,
                    "item_option_categories": [
                        [
                            "options_category_name": "Sides",
                            "required": true,
                            "single_selection": true,
                            "options": [
                                [
                                    "option_name": "Side1",
                                    "added_price": 30
                                ],
                                [
                                    "option_name": "Side2",
                                    "added_price": 40
                                ]
                            ]
                        ],
                        [
                            "options_category_name": "Extras",
                            "required": false,
                            "single_selection": false,
                            "options": [
                                [
                                    "option_name": "Extra BBQ Sauce",
                                    "added_price": 25
                                ],
                                [
                                    "option_name": "Extra Garlic Sauce",
                                    "added_price": 20
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "item_name": "Strawberry Smoothie",
                    "description": "",
                    "category": "Drinks",
                    "featured": false,
                    "item_image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/strawberry-banana-smoothie-4.jpg?alt=media&token=84974df0-e9ba-4047-8c16-84bb642204ca",
                    "price": 99,
                    "item_option_categories": []
                ]
            ]
        ]) { err in
            if let _ = err {
                DDLogDebug("Error writing chicka loca!")
            } else {
                DDLogDebug("Done writing chicka loka")
            }
        }
        
        restaurantRef.document("house_of_pancakes").setData([
            "name": "House of Pancakes",
            "categories": "Breakfast, Smoothies",
            "open_hours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
            "contact_number": "+63123456789",
            "geo_point": GeoPoint(latitude: 8.482862, longitude: 124.656042),
            "rating": 4.7,
            "image_url": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/Egg-free-french-toast_post.jpg?alt=media&token=8de1aa40-946c-4006-8cd6-6bc462e4236c",
            "address": "",
            "top_pick": false,
            "menu_items": [
                [
                    "item_name": "Brioche French Toast",
                    "description": "",
                    "category": "Breakfast",
                    "featured": true,
                    "price": 135,
                    "item_option_categories": [
                        [
                            "options_category_name": "Sides",
                            "required": true,
                            "single_selection": true,
                            "options": [
                                [
                                    "option_name": "Blueberries",
                                    "added_price": 0
                                ],
                                [
                                    "option_name": "Strawberries",
                                    "added_price": 0
                                ]
                            ]
                        ],
                        [
                            "options_category_name": "Extras",
                            "required": false,
                            "single_selection": false,
                            "options": [
                                [
                                    "option_name": "Extra butter packets",
                                    "added_price": 25
                                ],
                                [
                                    "option_name": "Extra syrup",
                                    "added_price": 20
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "item_name": "Banana Smoothie",
                    "description": "",
                    "category": "Drinks",
                    "featured": false,
                    "price": 99,
                    "item_option_categories": []
                ]
            ]
        ]) { err in
            if let _ = err {
                DDLogDebug("Error writing house of pancakes!")
            } else {
                DDLogDebug("Done writing house of pancakes!")
            }
        }
    }
}
