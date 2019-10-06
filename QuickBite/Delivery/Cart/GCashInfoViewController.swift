//
//  GCashIngoViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 10/6/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import PMSuperButton
import BEMCheckBox

class GCashInfoViewController: UIViewController {
    @IBOutlet weak var understandButton: PMSuperButton!
    @IBOutlet weak var dontShowAgainCheckbox: BEMCheckBox!
    @IBOutlet weak var dontShowAgainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dontShowAgainCheckbox.boxType = .square
        dontShowAgainCheckbox.onAnimationType = .fill
        dontShowAgainCheckbox.offAnimationType = .fill
        
        if UserDefaults.standard.bool(forKey: UDKeys.gcashIsNotFirstTime) == false {
            startUnderstandButtonCountdown()
            dontShowAgainCheckbox.isHidden = true
            dontShowAgainButton.isHidden = true
        } else {
            enableUnderstandButton()
        }
    }
    
    private func startUnderstandButtonCountdown() {
        var countdown = 5
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            countdown -= 1
            if countdown == 0 {
                self.enableUnderstandButton()
                timer.invalidate()
            } else {
                self.understandButton.setTitle("\(countdown)", for: .disabled)
            }
        }
    }
    
    private func enableUnderstandButton() {
        understandButton.setTitle("I Understand", for: .normal)
        understandButton.setEnabled(true, actuallyEnableOrDisable: true)
    }

    @IBAction func dontShowScreenAgainTapped(_ sender: Any) {
        dontShowAgainCheckbox.setOn(!dontShowAgainCheckbox.on, animated: true)
    }
    
    @IBAction func understandButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: UDKeys.gcashIsNotFirstTime)
        
        if dontShowAgainCheckbox.on {
            UserDefaults.standard.set(true, forKey: UDKeys.gcashDontShowInfoScreen)
        }
        
        if let user = UserUtil.currentUser, user.name.isNotEmpty, user.phone.isNotEmpty {
            performSegue(withIdentifier: "ReviewOrderSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "FinalizeOrderSegue", sender: nil)
        }
    }
    
}
