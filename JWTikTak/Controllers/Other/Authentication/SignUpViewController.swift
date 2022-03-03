//
//  SingupViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Actions
import SnapKit
import SCLAlertView
import SafariServices

class SignUpViewController: UIViewController {
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
    private let usernameField = AuthField(type: .username)
    
    private let signUpButton = AuthButton(type: .signUp, title: nil)
    private let termsOfServiceButton = AuthButton(type: .plain, title: "Terms of Service")
    
    lazy var subviews = [
        logoImageView,
        usernameField,
        emailField,
        passwordField,
        signUpButton,
        termsOfServiceButton
    ]
    
    var textFields: [AuthField] { subviews.compactMap { $0 as? AuthField }}

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create Account"
        view.backgroundColor = .systemBackground
        view.addSubviews(subviews)
        configureFields()
        configureButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// The spacing between the views.
        let interViewSpace = 20
        
        logoImageView.snp.makeConstraints { make in
            make.height.width.equalTo(UIScreen.main.bounds.width / 4)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaInsets.top + interViewSpace)
        }
        
        usernameField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(interViewSpace)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-interViewSpace)
            make.height.equalTo(60)
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(usernameField.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(usernameField)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameField.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(emailField)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(passwordField)
        }
        
        termsOfServiceButton.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(signUpButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }
    
    private func configureButtons() {
        signUpButton.add(event: .touchUpInside) { [weak self] in
            self?.dismissKeyboard()
            
            // TODO: Implement/Find textfield validation
            guard
                let username = self?.usernameField.text?.trimmingCharacters(in: .whitespaces),
                username.count >= 4,
                
                let email = self?.emailField.text?.trimmingCharacters(in: .whitespaces),
                !email.isEmpty,
                
                let password = self?.passwordField.text?.trimmingCharacters(in: .whitespaces),
                password.count >= 6
            else { return }
            
            AuthManager.shared.signUp(
                withUsername: username,
                email: email,
                password: password)
            {
                let appearance = SCLAlertView.SCLAppearance(showCloseButton: false, shouldAutoDismiss: true, hideWhenBackgroundViewIsTapped: true)
                let dismissOnTimeout = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 0.4, timeoutAction: { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                })
                
                switch $0 {
                    case .success(_):
                        // dismiss sign in vc
                        SCLAlertView(appearance: appearance)
                            .showSuccess("", timeout: dismissOnTimeout, animationStyle: .noAnimation)
                    case .failure(let error):
                        SCLAlertView()
                            .showError("Error", subTitle: error.localizedDescription)
                        print(error.localizedDescription)
                }
            }
        }
        
        termsOfServiceButton.add(event: .touchUpInside) { [weak self] in
            self?.dismissKeyboard()
            // Show or link to TOS
            guard let tosURL = URL(string: "https://www.jwplayer.com/legal/tos") else { return }
            
            let tosVC = SFSafariViewController(url: tosURL)
            self?.present(tosVC, animated: true)
        }
    }
    
    private func configureFields() {
        let doneButton = UIBarButtonItem(title: "Done", style: .done) { [weak self] in
            self?.dismissKeyboard()
        }
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        toolBar.items = [doneButton]

        textFields
            .forEach {
                $0.delegate = self
                $0.inputAccessoryView = toolBar
            }
    }
    
    private func dismissKeyboard() {
        textFields
            .forEach {$0.resignFirstResponder()}
    }
}

extension SignUpViewController: UITextFieldDelegate {
    // TODO: Respond to "Done" button press.
}
