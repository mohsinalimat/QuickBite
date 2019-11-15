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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLogDebug("Writing restaurants")
        writeRestaurants()
    }
    
    private func writeRestaurants() {
        let db = Firestore.firestore()
        let restaurantRef = db.collection("restaurants")
        
        chickaLoca(restaurantRef: restaurantRef)
//        houseOfPancakes(restaurantRef: restaurantRef)
//        silverRain(restaurantRef: restaurantRef)
//        kagayan(restaurantRef: restaurantRef)

    }
    
    private func kagayan(restaurantRef: CollectionReference) {
        //                 MARK: - Kagayan Coffee Cartel
        restaurantRef.document("kagayan_coffee_cartel").setData([
            "id": "F8D44BA9-0C9C-4BA1-A1DE-9D66278A6E8F",
            "name": "Kagayan Coffee Cartel",
            "categories": "Coffee, Smoothies",
            "openHours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
            "contactNumber": "+63123456789",
            "geoPoint": GeoPoint(latitude: 8.476213, longitude: 124.643741),
            "latitude": 8.476213,
            "longitude": 124.643741,
            "rating": 4.7,
            "imageUrl": "https://www.incimages.com/uploaded_files/image/970x450/getty_938993594_401542.jpg",
            "address": "88 Hayes St, Cagayan de Oro, 9000 Misamis Oriental",
            "topPick": true,
            "menuItems": [
                [
                    "itemName": "Cappucino",
                    "description": "",
                    "category": "Coffee",
                    "itemImageUrl": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/strawberry-banana-smoothie-4.jpg?alt=media&token=84974df0-e9ba-4047-8c16-84bb642204ca",
                    "featured": false,
                    "price": 135,
                    "itemOptionCategories": [
                        [
                            "optionsCategoryName": "Sides",
                            "required": true,
                            "singleSelection": true,
                            "options": [
                                [
                                    "optionName": "Side1",
                                    "addedPrice": 30
                                ],
                                [
                                    "optionName": "Side2",
                                    "addedPrice": 40
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "itemName": "Strawberry Smoothie",
                    "description": "",
                    "category": "Smoothies",
                    "featured": false,
                    "price": 99,
                    "itemOptionCategories": [
                        [
                            "optionsCategoryName": "Sides",
                            "required": true,
                            "singleSelection": true,
                            "options": [
                                [
                                    "optionName": "Side1",
                                    "addedPrice": 30
                                ],
                                [
                                    "optionName": "Side2",
                                    "addedPrice": 40
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]) { err in
            if let _ = err {
                DDLogDebug("Error writing kcc!")
            } else {
                DDLogDebug("Done writing kcc!")
            }
        }
    }
    
    private func silverRain(restaurantRef: CollectionReference) {
        //MARK: - Silver Rain
        restaurantRef.document("silver_rain").setData([
            "id": UUID().uuidString,
            "name": "SilverRain",
            "categories": "Korean BBQ",
            "openHours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
            "contactNumber": "+63123456789",
            "geoPoint": GeoPoint(latitude: 8.443897, longitude: 124.621148),
            "latitude": 8.443897,
            "longitude": 124.621148,
            "rating": 4.7,
            "imageUrl": "https://www.seriouseats.com/2019/07/20190619-korean-bbq-vicky-wasik-19-1500x1125.jpg",
            "address": "19 Masterson Ave, Upper Canitoan, Cagayan de Oro, 9000 Misamis Oriental",
            "topPick": true,
            "menuItems": [
                [
                    "itemName": "Grilled Pork Belly",
                    "description": "",
                    "category": "Pork",
                    "featured": false,
                    "price": 135,
                    "itemOptionCategories": []
                ],
                [
                    "itemName": "Bibimbap",
                    "description": "",
                    "category": "Beef",
                    "featured": false,
                    "price": 99,
                    "itemOptionCategories": []
                ]
            ]
        ]) { err in
            if let _ = err {
                DDLogDebug("Error writing silver_rain!")
            } else {
                DDLogDebug("Done writing silver_rain!")
            }
        }
        
    }
    
    private func houseOfPancakes(restaurantRef: CollectionReference) {
        //MARK: - House of Pancakes
        restaurantRef.document("house_of_pancakes").setData([
            "id": UUID().uuidString,
            "name": "House of Pancakes",
            "categories": "Breakfast, Smoothies",
            "openHours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
            "contactNumber": "+63123456789",
            "geoPoint": GeoPoint(latitude: 8.482862, longitude: 124.656042),
            "latitude": 8.482862,
            "longitude": 124.656042,
            "rating": 4.7,
            "imageUrl": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/Egg-free-french-toast_post.jpg?alt=media&token=8de1aa40-946c-4006-8cd6-6bc462e4236c",
            "address": "Claro M. Recto Ave, Cagayan de Oro, Misamis Oriental",
            "topPick": false,
            "menuItems": [
                [
                    "itemName": "Brioche French Toast",
                    "description": "",
                    "category": "Breakfast",
                    "featured": true,
                    "price": 135,
                    "itemOptionCategories": [
                        [
                            "optionsCategoryName": "Sides",
                            "required": true,
                            "singleSelection": true,
                            "options": [
                                [
                                    "optionName": "Blueberries",
                                    "addedPrice": 0
                                ],
                                [
                                    "optionName": "Strawberries",
                                    "addedPrice": 0
                                ]
                            ]
                        ],
                        [
                            "optionsCategoryName": "Extras",
                            "required": false,
                            "singleSelection": false,
                            "options": [
                                [
                                    "optionName": "Extra butter packets",
                                    "addedPrice": 25
                                ],
                                [
                                    "optionName": "Extra syrup",
                                    "addedPrice": 20
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "itemName": "Banana Smoothie",
                    "description": "",
                    "category": "Drinks",
                    "featured": false,
                    "price": 99,
                    "itemOptionCategories": []
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
    
    //MARK: - Chika Loca
    private func chickaLoca(restaurantRef: CollectionReference) {
        restaurantRef.document("chika_loca").setData([
            "id": "87244499-B449-4D25-8385-FAEC3B7FD3A4",
            "name": "Chika Loca!",
            "categories": "Chicken, BBQ",
            "openHours": "M0800-1600;T0800-1600;W0800-1600;R0800-1600;F0800-1400;S;U1030-1400",
            "contactNumber": "+631234567890",
            "alternativeContactNumber": "+634238204728",
            "geoPoint": GeoPoint(latitude: 8.476797, longitude: 124.645025),
            "latitude": 8.476797,
            "longitude": 124.645025,
            "rating": 3.5,
            "imageUrl": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/food_sample_inasal.jpg?alt=media&token=70e75f54-b368-4c44-a4b7-5bda1caf5c53",
            "address": "Pabayo corner, Mayor R. Chaves St, Cagayan de Oro, 9000 Misamis Oriental",
            "topPick": true,
            "menuItems": [
                [
                    "itemName": "5pc. BBQ Chicken Wings",
                    "description": "",
                    "category": "Chicken",
                    "featured": true,
                    "itemImageUrl": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/sample_food_3.jpg?alt=media&token=2eb2b213-df11-45cf-8867-66785d9f8075",
                    "price": 110,
                    "itemOptionCategories": [
                        [
                            "optionsCategoryName": "Sides",
                            "required": true,
                            "singleSelection": true,
                            "options": [
                                [
                                    "optionName": "Side1",
                                    "addedPrice": 30
                                ],
                                [
                                    "optionName": "Side2",
                                    "addedPrice": 40
                                ],
                                [
                                    "optionName": "Side3",
                                    "addedPrice": 30
                                ],
                                [
                                    "optionName": "Side4",
                                    "addedPrice": 0
                                ]
                            ]
                        ],
                        [
                            "optionsCategoryName": "Extras",
                            "required": false,
                            "singleSelection": false,
                            "options": [
                                [
                                    "optionName": "Extra BBQ Sauce",
                                    "addedPrice": 25
                                ],
                                [
                                    "optionName": "Extra Garlic Sauce",
                                    "addedPrice": 20
                                ],
                                [
                                    "optionName": "Extra BBQ Sauce",
                                    "addedPrice": 25
                                ],
                                [
                                    "optionName": "Extra Garlic Sauce",
                                    "addedPrice": 20
                                ],
                                [
                                    "optionName": "Extra BBQ Sauce",
                                    "addedPrice": 25
                                ],
                                [
                                    "optionName": "Extra Garlic Sauce",
                                    "addedPrice": 20
                                ],
                                [
                                    "optionName": "Extra BBQ Sauce",
                                    "addedPrice": 25
                                ],
                                [
                                    "optionName": "Extra Garlic Sauce",
                                    "addedPrice": 20
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "itemName": "Chicken Inasal",
                    "description": "",
                    "category": "Chicken",
                    "featured": true,
                    "itemImageUrl": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/inasal_2.png?alt=media&token=b789002b-96ff-47d2-8e43-defb8dff3c76",
                    "price": 119,
                    "itemOptionCategories": [
                        [
                            "optionsCategoryName": "Sides",
                            "required": true,
                            "singleSelection": true,
                            "options": [
                                [
                                    "optionName": "Side1",
                                    "addedPrice": 30
                                ],
                                [
                                    "optionName": "Side2",
                                    "addedPrice": 40
                                ]
                            ]
                        ],
                        [
                            "optionsCategoryName": "Extras",
                            "required": false,
                            "singleSelection": false,
                            "options": [
                                [
                                    "optionName": "Extra BBQ Sauce",
                                    "addedPrice": 25
                                ],
                                [
                                    "optionName": "Extra Garlic Sauce",
                                    "addedPrice": 20
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "itemName": "Strawberry Smoothie",
                    "description": "",
                    "category": "Drinks",
                    "featured": true,
                    "itemImageUrl": "https://firebasestorage.googleapis.com/v0/b/quickbite-1c608.appspot.com/o/strawberry-banana-smoothie-4.jpg?alt=media&token=84974df0-e9ba-4047-8c16-84bb642204ca",
                    "price": 99,
                    "itemOptionCategories": []
                ],
                [
                    "itemName": "6 pc. Spicy BBQ Wings",
                    "description": "",
                    "category": "Chicken",
                    "featured": true,
                    "itemImageUrl": "https://www.averiecooks.com/wp-content/uploads/2016/04/bbqchickenwings-5-650x975.jpg",
                    "price": 119,
                    "itemOptionCategories": [
                        [
                            "optionsCategoryName": "Sides",
                            "required": true,
                            "singleSelection": true,
                            "options": [
                                [
                                    "optionName": "Side1",
                                    "addedPrice": 30
                                ],
                                [
                                    "optionName": "Side2",
                                    "addedPrice": 40
                                ]
                            ]
                        ],
                        [
                            "optionsCategoryName": "Extras",
                            "required": false,
                            "singleSelection": false,
                            "options": [
                                [
                                    "optionName": "Extra BBQ Sauce",
                                    "addedPrice": 25
                                ],
                                [
                                    "optionName": "Extra Garlic Sauce",
                                    "addedPrice": 20
                                ]
                            ]
                        ]
                    ]
                ],
            ]
        ]) { err in
            if let _ = err {
                DDLogDebug("Error writing chicka loca!")
            } else {
                DDLogDebug("Done writing chicka loka")
            }
        }
    }
}
