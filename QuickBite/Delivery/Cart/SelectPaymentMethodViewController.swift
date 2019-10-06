//
//  SelectPaymentMethodViewController.swift
//  QuickBite
//
//  Created by Griffin Smalley on 10/6/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

protocol SelectPaymentMethodDelegate {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod)
}

enum PaymentMethod: Int {
    case cash
    case gcash
    case card
}

class SelectPaymentMethodViewController: UIViewController {
    public var delegate: SelectPaymentMethodDelegate?
    
    @IBAction func paymentMethodSelected(_ sender: Any) {
        guard let button = sender as? UIButton else {
            print("Could not cast sender as button!")
            return
        }
        
        delegate?.didSelectPaymentMethod(PaymentMethod(rawValue: button.tag)!)
    }
}
