//
//  SigninViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Actions
import SnapKit

class SignInViewController: UIViewController {
    /// Allows the presenting view controller to respond to this view controller's
    /// dismissal, or otherwise presenting its function.
    public var viewControllerCompletion: (() -> Void)?

    private let logoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode         = .scaleAspectFit
        imageView.image               = Asset.logo.image
        imageView.layer.cornerRadius  = 10
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private let emailField    = AuthField(type: .email)
    private let passwordField = AuthField(type: .password)
    
    private let forgotPasswordButton = AuthButton(type: .plain, title: "Forgot Password?")
    private let signInButton = AuthButton(type: .signIn, title: nil)
    private let signUpButton = AuthButton(type: .plain, title: "New user? Create account!")
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign In"
        view.backgroundColor = .systemBackground
        view.addSubviews([
            logoImageView,
            emailField,
            passwordField,
            signInButton,
            signUpButton,
            forgotPasswordButton
        ])
        
        emailField.delegate    = self
        passwordField.delegate = self
        
        configureButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let interViewSpace = 20
        
        
        logoImageView.snp.makeConstraints { make in
            make.height.width.equalTo(UIScreen.main.bounds.width / 4)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaInsets.top + interViewSpace)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(interViewSpace)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-interViewSpace)
            make.height.equalTo(60)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(emailField)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(passwordField)
        }
        
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(signInButton)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(forgotPasswordButton)
        }
    }
    
    
    private func configureButtons() {
        
        
        signInButton.add(event: .touchUpInside) {
            
        }
        
        signUpButton.add(event: .touchUpInside) {
            
        }
        
        forgotPasswordButton.add(event: .touchUpInside) {
            
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    
}
