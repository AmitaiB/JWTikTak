//
//  ConvertibleNumType.swift
//  ICanDOThis
//
//  Created by Amitai Blickstein on 1/19/19.
//  Copyright © 2019 Amitai Blickstein. All rights reserved.
//

import Foundation
import CoreGraphics

/**
 *  Give Int, CGFloats, and Floats a `doubleValue` property, like `NSNumber`.`doubleValue`
 By Erica Sadun, (Swift Cookbook recipe 5-1)
 */
//: Numbers that convert to other types
public protocol ConvertibleNumberType: DoubleRepresentable, NumberInitAble {}

// To extend the family to more types, add its implementation here.
public extension ConvertibleNumberType {
    var floatValue:    Float     { get {Float(doubleValue)}}
    var intValue:      Int       { get {lrint(doubleValue)}}
    var CGFloatValue:  CGFloat   { get {CGFloat(doubleValue)}}
    var UInt32Value:   UInt32    { get {UInt32(doubleValue)}}
    var UIntValue:     UInt      { get {UInt(doubleValue)}}
    var NSNumberValue: NSNumber  { get {NSNumber(value: doubleValue)}}
    var intStringValue:String    { get {String(intValue)}}
}

/// Numbers that can be fully represented as Doubles.
public protocol DoubleRepresentable {
    var doubleValue: Double { get }
}


// MARK: - DoubleRepresentable

extension Double: ConvertibleNumberType {
    public var doubleValue: Double {self}
    public init<T: ConvertibleNumberType>(_ value: T) {
        self = value.doubleValue
    }
}

extension Int:     ConvertibleNumberType {
    public var doubleValue: Double { Double(self) }
    public init<T: ConvertibleNumberType>(_ value: T) {
        self = value.intValue
    }
}

extension CGFloat: ConvertibleNumberType {
    public var doubleValue: Double { Double(self) }
    public init<T: ConvertibleNumberType>(_ value: T) {
        self = value.CGFloatValue
    }
}

extension Float:   ConvertibleNumberType {
    public var doubleValue: Double { Double(self)}
    public init<T: ConvertibleNumberType>(_ value: T) {
        self = value.floatValue
    }
}

extension UInt32:  ConvertibleNumberType {
    public var doubleValue: Double { self.NSNumberValue.doubleValue }
    /// - warning: Will crash if value ≥ 0 is not true.
    public init<T: ConvertibleNumberType>(_ value: T) {
        print(" *** Warning: UInt generic inits are unsafe for invalid (negative) values. ***")
        self = value.UInt32Value
    }
}

extension UInt: ConvertibleNumberType {
    public var doubleValue: Double { self.NSNumberValue.doubleValue }
    /// - warning: Will crash if value ≥ 0 is not true.
    public init<T>(_ value: T) where T : ConvertibleNumberType {
        print(" *** Warning: UInt generic inits are unsafe for invalid (negative) values. ***")
        self = value.UIntValue
    }
}


// MARK: - Convenience Helpers

// I do not want to think about the recursive conformance going on here.
/// Allows `T(someNumber)`
public protocol NumberInitAble {
    init<T: ConvertibleNumberType>(_ value: T)
}


// MARK: - Operators
// MARK: Vanilla Arithmetic Operations

func +<T: ConvertibleNumberType, U: ConvertibleNumberType>(lhs: T?, rhs: U?) -> T {
    return T((lhs?.doubleValue ?? 0.0) + (rhs?.doubleValue ?? 0.0))
}

func -<T: ConvertibleNumberType, U: ConvertibleNumberType>(lhs: T?, rhs: U?) -> T {
    return T((lhs?.doubleValue ?? 0.0) - (rhs?.doubleValue ?? 0.0))
}

func *<T: ConvertibleNumberType, U: ConvertibleNumberType>(lhs: T?, rhs: U?) -> T {
    return T((lhs?.doubleValue ?? 1.0) * (rhs?.doubleValue ?? 1.0))
}

func /<T: ConvertibleNumberType, U: ConvertibleNumberType>(lhs: T?, rhs: U?) -> T {
    return T((lhs?.doubleValue ?? 1.0) / (rhs?.doubleValue ?? 1.0))
}
