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
    
    func fadeIn(withDuration duration: TimeInterval = 1, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {self.alpha = 1 }, completion: completion)
    }
    
    func fadeOut(withDuration duration: TimeInterval = 1, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {self.alpha = 0 }, completion: completion)
    }
}
