//
//  RecordButton.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 3/9/22.
//

import UIKit


/// A UIButton subclass with some UI presets, and has a recording/notRecording state.
class RecordButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = nil
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.5
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = height/2
    }
    enum State {
        case isRecording
        case isNotRecording
    }
    
    public func toggleUI(for state: State) {
        backgroundColor = state == .isRecording ? .systemRed : nil
    }
}
