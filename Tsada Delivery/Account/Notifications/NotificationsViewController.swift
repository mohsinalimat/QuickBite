//
//  NotificationsViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/30/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var smsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = UserUtil.currentUser!
        
        pushSwitch.isOn = user.pushNotificationsEnabled
        smsSwitch.isOn = user.smsNotificationsEnabled
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserUtil.setPushNotificationEnabled(pushSwitch.isOn)
        UserUtil.setSmsNotificationEnabled(smsSwitch.isOn)
    }
}
