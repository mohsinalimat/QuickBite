//
//  CustomLogger.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/17/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import CocoaLumberjack

class CustomFormatter: NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        var logLevel = ""
        
        switch logMessage.flag {
        case .error     : logLevel = "💔"
        case .warning   : logLevel = "💛"
        case .info      : logLevel = "💙"
        case .debug     : logLevel = "💚"
        default         : logLevel = ""
        }
        return logLevel + " | " + logMessage.message
    }
}
