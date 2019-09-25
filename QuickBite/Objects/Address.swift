//
//  Address.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/25/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation

// Has to be a class because isDefault is mutable
class Address: Codable {
    let id: UUID
    var floorDeptHouseNo: String
    var street: String
    var barangay: String
    var building: String
    var landmark: String
    var isSelected: Bool
    var isDefault: Bool
    
    var dictionary: [String : Any] {
        return [
            "floor_dept_house_no": floorDeptHouseNo,
            "street": street,
            "barangay": barangay,
            "building": building,
            "landmark": landmark,
            "is_default": isDefault
        ]
    }

    init(floorDeptHouseNo: String, street: String, barangay: String, building: String, landmark: String, isSelected: Bool, isDefault: Bool = false) {
        self.id = UUID()
        self.floorDeptHouseNo = floorDeptHouseNo
        self.street = street
        self.barangay = barangay
        self.building = building
        self.landmark = landmark
        self.isSelected = isSelected
        self.isDefault = isDefault
    }
    
    convenience init?(dictionary: [String : Any]) {
        guard let street = dictionary["street"] as? String else { return nil }

        let floorDeptHouseNo = dictionary["floor_dept_house_no"] as? String ?? ""
        let barangay = dictionary["barangay"] as? String ?? ""
        let building = dictionary["building"] as? String ?? ""
        let landmark = dictionary["landmark"] as? String ?? ""
        let isDefault = dictionary["is_default"] as? Bool ?? false

        self.init(floorDeptHouseNo: floorDeptHouseNo,
                  street: street,
                  barangay: barangay,
                  building: building,
                  landmark: landmark,
                  isSelected: false,
                  isDefault: isDefault)
    }

    func toString() -> String {
        let addressLines = [floorDeptHouseNo, street, barangay, building, landmark]
        var fullAddressString = ""
        for line in addressLines {
            if line.isNotEmpty {
                fullAddressString.append(line + ", ")
            }
        }
        return fullAddressString.chompLast(2)
    }
}
