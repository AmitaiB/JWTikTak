//
//  AuthButton.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 3/2/22.
//

import UIKit

class AuthButton: UIButton {

    enum ButtonType {
        case signIn
        case signUp
        case plain
        
        var title: String {
            switch self {
                case .signIn: return "Sign In"
                case .signUp: return "Sign Up"
                case .plain:  return "-"
            }
        }
    }
    
    let type: ButtonType
    
    /// - Parameters:
    ///   - type: A `ButtonType`
    ///   - title: For `.plain` button types only.
    init(type: ButtonType, title: String?) {
        self.type = type
        super.init(frame: .zero)
        configureUI()
        
        type == .plain ?
        setTitle(title, for: .normal) : nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        type != .plain ?
        setTitle(type.title, for: .normal) : nil
        
        setTitleColor(.white, for: .normal)
        switch type {
            case .signIn: backgroundColor = .systemBlue
            case .signUp: backgroundColor = .systemGreen
            case .plain:
                setTitleColor(.link, for: .normal)
                backgroundColor = .clear
        }
        
        titleLabel?.font    = .systemFont(ofSize: 18, weight: .semibold)
        layer.cornerRadius  = 8
        layer.masksToBounds = true
    }

}
