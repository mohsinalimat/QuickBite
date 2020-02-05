//
//  AddressTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/30/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {
    @IBOutlet weak var currentlySelectedLabel: SmallCapsLabel!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var unitAndStreet: UILabel!
    @IBOutlet weak var buildingLandmark: UILabel!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var checkmarkWidth: NSLayoutConstraint!
    
    private var settingsMode: Bool = false
    
    func setup(_ address: Address, settingsMode: Bool) {
        self.settingsMode = settingsMode
        
        // Show "Default" label or show selecting checkmark depending on context
        if settingsMode {
            checkmarkWidth.constant = 0
            currentlySelectedLabel.alpha = address.isSelected ? 1 : 0
        } else {
            checkmark.alpha = address.isSelected ? 1 : 0
        }
        
        addressName.text = address.displayName
        
        // Calculate second line
        if address.floorDoorUnitNo.isNotEmpty {
            if address.userNickname.isNotEmpty {
                // First line is set to user nickname, so append street
                unitAndStreet.text = address.floorDoorUnitNo + ", " + address.street
            } else {
                unitAndStreet.text = address.floorDoorUnitNo
            }
        } else if address.userNickname.isNotEmpty {
            // No unit or floor set, but there is a userNickname
            unitAndStreet.text = address.street
        } else if let unitStreet = unitAndStreet {
            // No unit or floor and no userNickname, hide second line
            unitStreet.removeFromSuperview()
        }
        
        if address.buildingLandmark.isNotEmpty {
            buildingLandmark.text = address.buildingLandmark
        } else if let bdLandmark = buildingLandmark{
            bdLandmark.removeFromSuperview()
        }
        
        if address.instructions.isNotEmpty {
            instructions.text = "Instructions: " + address.instructions
        } else if let instr = instructions {
            instr.removeFromSuperview()
        }
    }
}
