//
//  FirebaseSerializer.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/25/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import CocoaLumberjack

struct FBSerializer {
    static func serializeMenuItems(_ rawArray: Array<[String : Any]>) -> [MenuItem] {
        var convertedMenuItems: [MenuItem] = []
        for item in rawArray {
            if let menuItem = MenuItem(dictionary: item) {
                convertedMenuItems.append(menuItem)
            } else {
                DDLogError("Couldn't create MenuItem from dictionary: \(item)")
            }
        }
        return convertedMenuItems
    }
}
