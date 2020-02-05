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

enum PaymentMethod: String {
    case cash = "Cash"
    case gcash = "GCash"
    case card = "Credit/Debit Card"
}

class SelectPaymentMethodViewController: UIViewController {
    public var delegate: SelectPaymentMethodDelegate?
    
    @IBAction func paymentMethodSelected(_ sender: Any) {
        let button = sender as! UIButton
        
        let paymentMethod = PaymentMethod(rawValue: button.titleLabel!.text!)!
        
        Cart.paymentMethod = paymentMethod
        delegate?.didSelectPaymentMethod(paymentMethod)
    }
}
