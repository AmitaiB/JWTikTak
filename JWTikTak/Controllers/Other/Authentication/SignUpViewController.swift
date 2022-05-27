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
import IQKeyboardManagerSwift

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
    
    private let usernameField = AuthField(type: .username)
    private let emailField    = AuthField(type: .email)
    private let passwordField = AuthField(type: .newPassword)
    
    private let signUpButton         = AuthButton(type: .signUp, title: nil)
    private let termsOfServiceButton = AuthButton(type: .plain,  title: "Terms of Service")
    
    lazy var subviews = [
        logoImageView,
        usernameField,
        emailField,
        passwordField,
        signUpButton,
        termsOfServiceButton
    ]
    
    // TODO: No longer needed with IQKM
    var textFields: [AuthField] { subviews.compactMap { $0 as? AuthField }}

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create Account"
        view.backgroundColor = .systemBackground
        view.addSubviews(subviews)
        configureButtons()
        configureKeyboard()
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
            make.top.equalTo(emailField.snp.bottom).offset(interViewSpace)
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
    
    private func configureKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    private func configureButtons() {
        // Unowned is safe, since the button is a subview of this object.
        // TODO: Replace the Actions dependency with iOS's `addAction: UIAction`
        signUpButton.add(event: .touchUpInside) { [unowned self] in
            
            // TODO: Implement/Find textfield validation
            guard
                let username = self.usernameField.text?.trimmingCharacters(in: .whitespaces),
                username.count >= 4,
                
                let email = self.emailField.text?.trimmingCharacters(in: .whitespaces),
                !email.isEmpty,
                
                let password = self.passwordField.text?.trimmingCharacters(in: .whitespaces),
                password.count >= 6
            else { return }
            
            AuthManager.shared.signUp(
                withUsername: username,
                email: email,
                password: password,
                completion: self.showAlertHandlerForStringResult)
        }
        
        termsOfServiceButton.add(event: .touchUpInside) { [weak self] in
            // Show or link to TOS
            guard let tosURL = URL(string: "https://www.jwplayer.com/legal/tos") else { return }
            
            let tosVC = SFSafariViewController(url: tosURL)
            self?.present(tosVC, animated: true)
        }
    }
    
    // MARK: - UI Alert handlers
//    lazy var showAlertHandlerForDataResult:  AuthDataResultCompletion  = { [weak self] in
//        switch $0 {
//            case .success(let result):
//                self?.showAlertForSuccess()
//            case .failure(let error):
//                self?.showAlert(forError: error)
//        }
//    }
//
    lazy var showAlertHandlerForStringResult: AuthStringResultCompletion = { [weak self] in
        switch $0 {
            case .success(let result):
                self?.showAlertForSuccess()
            case .failure(let error):
                self?.showAlert(forError: error)
        }
    }

    // TODO: Replace above two handler with this single one.
    /*
    lazy var showAlertForResult: (Result<Any, Error>) -> Void = { [weak self] in
        switch $0 {
            case .success(_):
                self?.showAlertForSuccess()
            case .failure(let error):
                self?.showAlert(forError: error)
        }
    }
    */
    
    // A quick UI acknowledgement of success, seen-then-gone
    private func showAlertForSuccess(message: String? = nil) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            shouldAutoDismiss: true,
            hideWhenBackgroundViewIsTapped: true
        )
        
        let dismissOnTimeout = SCLAlertView.SCLTimeoutConfiguration(
            timeoutAction: { [weak self] in
                self?.dismiss(animated: true, completion: nil) }
        )
        
        // dismiss sign in vc
        SCLAlertView(appearance: appearance)
            .showSuccess("Success!",
                         timeout: dismissOnTimeout,
                         animationStyle: .noAnimation)
    }
    
    private func showAlert(forError error: Error) {
        SCLAlertView().showError("Error", subTitle: error.localizedDescription)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    // TODO: Respond to "Done" button press.
}
