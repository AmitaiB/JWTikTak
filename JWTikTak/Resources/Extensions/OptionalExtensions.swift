//
//  OptionalExtensions.swift
//  TestApp
//
//  Created by Amitai Blickstein on 6/4/19.
//  Copyright © 2019 JWPlayer. All rights reserved.
//

import Foundation

// MARK: - Notification Syntactic Sugar Helpers
extension Optional {
    /// If the optional `isSome`, **then** call the closure on its unwrapped value.
    /// Useful shorthand for conditional value assignment.
    func ifThen(_ funcIfSome: (Wrapped) -> Void) {
        if let wrapped = self { funcIfSome(wrapped) }
    }
    
    var isSome: Bool { return self != nil }
    var isNone: Bool { return !isSome }
}

