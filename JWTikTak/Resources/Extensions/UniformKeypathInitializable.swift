//
//  UniformKeypathInitializable.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 4/28/22.
//  Actually created by Erica Sadun and friends:
// https://ericasadun.com/2018/02/16/better-initializers-and-defaulted-arguments/
//

import Foundation

/// Allows dictionary literal initialization for any
/// conforming type that declares `typealias Value`,
/// where `Value` refers to a uniform property Type
/// that can be set through a keypath-value dictionary
///
/// - Example:
///   ```
///   extension CGPoint : UniformKeypathInitializable {
///     public typealias Value = CGFloat
///   }
///
///   let p: CGPoint = [\.x: 0, \.y: 20]
///   ```
public protocol UniformKeypathInitializable : ExpressibleByDictionaryLiteral {
    /// Allow zero-argument initializer
    init()
    
}

extension UniformKeypathInitializable {
    /// Initializes each member of a keypath-value
    /// dictionary, allowing the type to be initialized
    /// with a dictionary literal
    public init(dictionaryLiteral elements: (WritableKeyPath<Self, Value>, Value)...) {
        self.init()
        for (property, value) in elements {
            self[keyPath: property] = value
        }
    }
}

// MARK: - UIEdgeInsets

import UIKit

extension UIEdgeInsets: UniformKeypathInitializable {
    public typealias Value = CGFloat
    public typealias Key = WritableKeyPath<UIEdgeInsets, CGFloat>
    
    public init(dictionaryLiteral elements: (WritableKeyPath<UIEdgeInsets, CGFloat>, CGFloat)...) {
        self = UIEdgeInsets()
        for (inset, value) in elements {
            self[keyPath: inset] = value
        }
    }
    
    /// Sets the `top` and `bottom` values.
    public var vertical: CGFloat {
        get { return 0 } // meaningless but not fatal
        set { (top, bottom) = (newValue, newValue) }
    }
    
    /// Sets the `left` and `right` values.
    public var horizontal: CGFloat {
        get { return 0 } // meaningless but not fatal
        set { (left, right) = (newValue, newValue) }
    }
    
    /// Sets all 4 values for `UIEdgeInsets`.
    public var all: CGFloat {
        get { return 0 } // meaningless but not fatal
        set { (vertical, horizontal) = (newValue, newValue) }
    }
}
