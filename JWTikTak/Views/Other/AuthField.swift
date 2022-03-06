//
//  AuthField.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 3/2/22.
//

import UIKit

class AuthField: UITextField {

    enum FieldType {
        case username
        case email
        case password
        
        var title: String {
            switch self {
                case .username: return "Username"
                case .email:    return "Email Address"
                case .password: return "Password"
            }
        }
    }

    private let type: FieldType
    
    init(type: FieldType) {
        self.type = type
        
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        layer.cornerRadius  = 8
        layer.masksToBounds = true
        backgroundColor = .secondarySystemBackground
        placeholder     = type.title

        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: height))
        leftViewMode           = .always
        returnKeyType          = .done
        autocorrectionType     = .no
        autocapitalizationType = .none

        // Keyboard Type
        switch type {
            case .username:
                keyboardType    = .default
                textContentType = .username
            case .email:
                keyboardType    = .emailAddress
                textContentType = .emailAddress
            case .password:
                isSecureTextEntry = true
                textContentType   = .newPassword
        }
    }
}
