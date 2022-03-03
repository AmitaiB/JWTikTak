//
//  SigninViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Actions
import SnapKit
import SCLAlertView

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
        
        configureFields()
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
        signInButton.add(event: .touchUpInside) { [weak self] in
            self?.dismissKeyboard()
            
            // TODO: Better textfield validation
            guard
                let email = self?.emailField.text?.trimmingCharacters(in: .whitespaces),
                let password = self?.passwordField.text?.trimmingCharacters(in: .whitespaces),
                !email.isEmpty,
                password.count >= 6
            else { return }

            AuthManager.shared.signIn(withEmail: email, password: password) {
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
        
        signUpButton.add(event: .touchUpInside) { [weak self] in
            self?.dismissKeyboard()
            let signUpVC = SignUpViewController()
            self?.navigationController?.pushViewController(signUpVC, animated: true)
        }
        
        forgotPasswordButton.add(event: .touchUpInside) {
            self.dismissKeyboard()
            // TODO: Implement Password Retrieval
            print(" *** IMPLEMENT PASSWORD RESET HERE")
        }
    }
    
    private func configureFields() {
        emailField.delegate    = self
        passwordField.delegate = self

        let doneButton = UIBarButtonItem(title: "Done", style: .done) { [weak self] in
            self?.dismissKeyboard()
        }
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        toolBar.items = [doneButton]
        
        emailField.inputAccessoryView    = toolBar
        passwordField.inputAccessoryView = toolBar
    }
    
    private func dismissKeyboard() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
}

extension SignInViewController: UITextFieldDelegate {
    // TODO: Respond to "Done" button press.
}
