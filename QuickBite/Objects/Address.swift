//
//  Address.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/25/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseFirestore

// Has to be a class because isDefault is mutable
class Address: Codable {
    let id: String
    var userNickname: String
    var floorDoorUnitNo: String
    var street: String
    var buildingLandmark: String
    var instructions: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var isDefault: Bool
    
    // Local properties
    var isSelected: Bool
    var displayName: String {
        return userNickname.isNotEmpty ? userNickname : street
    }
    
    var dictionary: [String : Any] {
        return [
            "id": id,
            "userNickname": userNickname,
            "floorDoorUnitNo": floorDoorUnitNo,
            "street": street,
            "buildingLandmark": buildingLandmark,
            "instructions": instructions,
            "geoPoint": GeoPoint(latitude: latitude, longitude: longitude),
            "isDefault": isDefault
        ]
    }

    init(id: String = UUID().uuidString,
         userNickname: String,
         floorDoorUnitNo: String,
         street: String,
         buildingLandmark: String,
         instructions: String,
         latitude: CLLocationDegrees,
         longitude: CLLocationDegrees,
         isSelected: Bool,
         isDefault: Bool) {
        self.id = id
        self.userNickname = userNickname
        self.floorDoorUnitNo = floorDoorUnitNo
        self.street = street
        self.buildingLandmark = buildingLandmark
        self.instructions = instructions
        self.latitude = latitude
        self.longitude = longitude
        self.isSelected = isSelected
        self.isDefault = isDefault
    }
    
    convenience init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
            let street = dictionary["street"] as? String,
            let geoPoint = dictionary["geoPoint"] as? GeoPoint else { return nil }

        let userNickname = dictionary["userNickname"] as? String ?? ""
        let floorDoorUnitNo = dictionary["floorDoorUnitNo"] as? String ?? ""
        let buildingLandmark = dictionary["buildingLandmark"] as? String ?? ""
        let instructions = dictionary["instructions"] as? String ?? ""
        let isDefault = dictionary["isDefault"] as? Bool ?? false
        
        self.init(id: id,
                  userNickname: userNickname,
                  floorDoorUnitNo: floorDoorUnitNo,
                  street: street,
                  buildingLandmark: buildingLandmark,
                  instructions: instructions,
                  latitude: CLLocationDegrees(geoPoint.latitude),
                  longitude: CLLocationDegrees(geoPoint.longitude),
                  isSelected: false,
                  isDefault: isDefault)
    }

    func toString() -> String {
        let streetName = userNickname.isNotEmpty ? userNickname : street
        let addressLines = [floorDoorUnitNo, streetName + ", Cagayan de Oro", buildingLandmark, instructions,]
        var fullAddressString = ""
        for line in addressLines {
            if line.isNotEmpty {
                fullAddressString.append(line + ", ")
            }
        }
        return fullAddressString.chompLast(2)
    }
}
