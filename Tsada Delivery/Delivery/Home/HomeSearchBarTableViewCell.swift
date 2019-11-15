//
//  SearchTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/1/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class HomeSearchBarTableViewCell: UITableViewCell {
    @IBOutlet weak var searchPrompt: UILabel!
    
    private var searchPrompts = ["inasal", "breakfast", "pizza", "shawarma", "burgers", "lechon manok",
                                 "seafood", "donuts", "bakery"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchPrompt.alpha = 0
        
        let promptTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { timer in
            UIView.animate(withDuration: 0.4, animations: {
                self.searchPrompt.alpha = 0
            }) { _ in
                self.searchPrompt.text = "\"\(self.searchPrompts[Int.random(in: 0..<self.searchPrompts.count)])\""
                UIView.animate(withDuration: 0.4, animations: {
                    self.searchPrompt.alpha = 1
                })
            }
        }
        promptTimer.fire()
    }
}
