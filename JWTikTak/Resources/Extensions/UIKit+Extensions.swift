//
//  UIKit+Extensions.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/13/22.
//

import Foundation
import UIKit

// To help with frame-based layouts.
extension UIView {
    var width: CGFloat  { frame.size.width }
    var height: CGFloat { frame.size.height }
    var left: CGFloat   { frame.origin.x }
    var right: CGFloat  { left + width }
    var top: CGFloat    { frame.origin.y }
    var bottom: CGFloat { top + height }
}
