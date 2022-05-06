//
//  UITextView+Placeholder.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 4/28/22.
// See: https://tij.me/blog/adding-placeholders-to-uitextviews-in-swift/

//  UITextViewPlaceholder.swift
//  TextViewPlaceholder
//
//  Copyright (c) 2017 Tijme Gommers <tijme@finnwea.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

fileprivate let kTagID = 10101

/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    var placeholderLabel: UILabel? {self.viewWithTag(kTagID) as? UILabel}
    
    /// The UITextView placeholder text
    @IBInspectable public var placeholder: String? {
        get { placeholderLabel?.text }
        set { adjustPlaceholderOrCreateIfNeeded(text: newValue) }
    }
    
    @IBInspectable public var placeholderColor: UIColor {
        get { placeholderLabel?.textColor ?? .lightGray }
        set { adjustPlaceholderOrCreateIfNeeded(color: newValue)   }
    }
         
    @IBInspectable public var placeholderFont: UIFont {
        get { placeholderLabel?.font ?? self.font ?? .systemFont(ofSize: UIFont.systemFontSize) }
        set { adjustPlaceholderOrCreateIfNeeded(font: newValue) }
    }
    
    var adjustedTopInset: CGFloat  {textContainerInset.top + 10}
    @IBInspectable public var placeholderTopInset: CGFloat {
        get { placeholderLabel?.frame.origin.y ?? adjustedTopInset }
        set { adjustPlaceholderOrCreateIfNeeded(topInset: newValue) }
    }
    
    @IBInspectable public var placeholderLeftInset: CGFloat {
        get { placeholderLabel?.frame.origin.y ?? textContainer.lineFragmentPadding }
        set { adjustPlaceholderOrCreateIfNeeded(leftInset: newValue) }
    }

    /// The placeholder should hide when the UITextView has text.
    ///
    /// - Parameter textView: The UITextView that got updated.
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.placeholderLabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    /// Resize the placeholder UILabel to make sure it is in the same position as the UITextView text.
    private func resizePlaceholder() {
        if let placeholderLabel = self.placeholderLabel {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.adjustedTopInset
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView.
    private func adjustPlaceholderOrCreateIfNeeded(text: String? = "",
                                font: UIFont? = nil,
                                color: UIColor? = nil,
                                topInset: CGFloat? = nil,
                                leftInset: CGFloat? = nil
    ) {
        // Setup should only be needed after creating a new label.
        let setupNeeded = (placeholderLabel == nil)
        
        let placeholderLabel = placeholderLabel ?? UILabel()
        
        placeholderLabel.text           =? text
        placeholderLabel.font           =? (font  ?? self.font)
        placeholderLabel.textColor      =? (color ?? .lightGray)
        placeholderLabel.frame.origin.y = topInset  ?? adjustedTopInset
        placeholderLabel.frame.origin.x = leftInset ?? textContainer.lineFragmentPadding
        placeholderLabel.sizeToFit()

        placeholderLabel.isHidden = !self.text.isEmpty

        // This dance is only necessary because no properties can be stored in an extension.
        guard setupNeeded else { return }
        
        placeholderLabel.tag = kTagID
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()

        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification,
                                               object: self,
                                               queue: .main) { _ in
            self.placeholderLabel?.isHidden = !self.text.isEmpty
        }
    }
}
