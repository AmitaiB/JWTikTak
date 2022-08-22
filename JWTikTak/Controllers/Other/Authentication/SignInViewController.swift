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
import IQKeyboardManagerSwift

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
    
    private let forgotPasswordButton   = AuthButton(type: .plain, title: "Forgot Password?")
    private let signInButton           = AuthButton(type: .signIn, title: nil)
    private let showSignUpScreenButton = AuthButton(type: .plain, title: "New user? Create account!")
    
    lazy var subviews = [
        emailField,
        passwordField,
        forgotPasswordButton,
        signInButton,
        showSignUpScreenButton,
    ]
    
    var textFields: [AuthField] { subviews.compactMap{$0 as? AuthField}}
    
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
            showSignUpScreenButton,
            forgotPasswordButton
        ])
        
        configureKeyboard()
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
        
        showSignUpScreenButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(interViewSpace)
            make.width.height.centerX.equalTo(forgotPasswordButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }
    
    private func configureKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    // TODO: Optimize here in parity with SignUpViewController
    private func configureButtons() {
        signInButton.add(event: .touchUpInside) { [weak self] in
            
            // TODO: Better textfield validation
            guard
                let email = self?.emailField.text?.trimmingCharacters(in: .whitespaces),
                let password = self?.passwordField.text?.trimmingCharacters(in: .whitespaces),
                !email.isEmpty,
                password.count >= 6
            else { return }

            AuthManager.shared.signIn(withEmail: email, password: password) {
                // Prepare alert appearance and timeout
                let successAppearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false,
                    hideWhenBackgroundViewIsTapped: true
                )
                let timeoutHandler = SCLAlertView.SCLTimeoutConfiguration(
                    timeoutAction: { [weak self] in
                        self?.dismiss(animated: true, completion: nil)
                    }
                )
                
                switch $0 {
                    case .success(let email):
                        // dismiss sign in vc
                        HapticsManager.shared.vibrate(for: .success)
                        SCLAlertView(appearance: successAppearance)
                            .showSuccess("User \(email) signed in.",
                                         timeout: timeoutHandler,
                                         animationStyle: .noAnimation)
                    case .failure(let error):
                        HapticsManager.shared.vibrate(for: .error)
                        SCLAlertView()
                            .showError(L10n.error, subTitle: error.localizedDescription)
                        print(error.localizedDescription)
                        self?.passwordField.text = nil
                }
            }
        }
        
        showSignUpScreenButton.add(event: .touchUpInside) { [weak self] in
            let signUpVC = SignUpViewController()
            self?.navigationController?.pushViewController(signUpVC, animated: true)
        }
        
        forgotPasswordButton.add(event: .touchUpInside) { [weak self] in
            // TODO: Implement Password Retrieval
            print(" *** IMPLEMENT PASSWORD RESET HERE")
        }
    }
    
    private func configureFields() {

        let doneButton = UIBarButtonItem(title: "Done", style: .done) { [weak self] in
            self?.dismissKeyboard()
        }
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        toolBar.items = [doneButton]
        
        textFields.forEach {
            $0.delegate = self
            $0.inputAccessoryView = toolBar
        }
    }
    
    private func dismissKeyboard() {
        textFields.forEach {$0.resignFirstResponder()}
    }
}

extension SignInViewController: UITextFieldDelegate {
    // TODO: Respond to "Done" button press.
}
