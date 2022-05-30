//
//  SCLAlert+Extensions.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 3/8/22.
//

import Foundation
import SCLAlertView

extension SCLAlertView.SCLTimeoutConfiguration {
    public init(timeoutAction: @escaping ActionType) {
        self.init(timeoutValue: .defaultTimeoutInterval, timeoutAction: timeoutAction)
    }
}

extension TimeInterval {
    /// Currently set to `1.0`
    fileprivate static var defaultTimeoutInterval: TimeInterval { 1 }
}

extension SCLAlertView.SCLAppearance {
    static let defaultCloseButtonIsHidden = Self(showCloseButton: false)
}
