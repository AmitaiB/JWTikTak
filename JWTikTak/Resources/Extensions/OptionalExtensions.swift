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
    func ifSome(_ funcIfSome: (Wrapped) -> Void) {
        if let wrapped = self { funcIfSome(wrapped) }
    }

    /// If the optional `isNone`, **then** call the closure.
    /// Useful shorthand for conditional value assignment.
    func ifNone(_ funcIfNone: () -> Void) {
        if self.isNone { funcIfNone() }
    }
    
    var isSome: Bool { self != nil }
    var isNone: Bool { !isSome }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}

// MARK: Arrays
extension Optional {
    
    /// `self = (self ?? []) + [element]`
    mutating func coalescingAppend<E>(_ element: Wrapped.Element) where Wrapped == [E] {
        self = (self ?? []) + [element]
    }
    
    /// `self = (self ?? []) + [newElements]`
    mutating func coalescingAppend<S>(contentsOf newElements: S) where S: Sequence, Wrapped == [S.Element] {
        self = (self ?? []) + newElements
    }
}

infix operator =?? // Weak Assignment
/**
 Assign value only if lhs does not yet have one.
 */
public func =??<T>(lhs: inout T?, rhs: T?) {
    lhs = lhs ?? rhs
}
