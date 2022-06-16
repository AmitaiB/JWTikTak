//
//  SettingsViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
//import SettingsViewController
import SCLAlertView
import Appirater

extension SettingsViewController {
    static var standard = SettingsViewController(settings: standardSettings)
    
    static var standardSettings: [Setting] {
        [
            BoolSetting(name: "Save Videos", initialValue: true) { shouldSaveVideos in
                print(" ** shouldSaveVideos set to \(shouldSaveVideos)")
            },
            ButtonSetting(name: "Enjoying the app?",
                          title: "Rate App",
                          onTapHandler: { _ in
                              // TODO: Replace with StoreKit solution, e.g., https://www.raywenderlich.com/9009-requesting-app-ratings-and-reviews-tutorial-for-ios
                              // see: https://developer.apple.com/documentation/storekit/requesting_app_store_reviews
                              Appirater.tryToShowPrompt()
            }),
            ButtonSetting(name: "Spread the joy?", title: "Share App", onTapHandler: { _ in
               guard let url = URL(string: "https://www.facebook.com")
                else { return }
                
                let shareVC = UIActivityViewController(
                    activityItems: [url],
                    applicationActivities: []
                )
                
                if let scene = UIApplication.shared
                    .connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                {
                    scene.keyWindow?.rootViewController?.present(shareVC, animated: true)
                }
            }),
            ButtonSetting(name: "Sign Out", title: "Log me out!", onTapHandler: { _ in
                let alertView = SCLAlertView(appearance: .defaultCloseButtonIsHidden)
                alertView.addButton(L10n.logMeOut) { signOut() }
                alertView.addButton(L10n.cancel) {}
                
                alertView.showWarning(L10n.signOut,
                                      subTitle: "Would you like to sign out?",
                                      animationStyle: .bottomToTop
                )
            })
        ]
    }
    
    static var topViewController: UIViewController? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
    
    static func signOut() {
        AuthManager.shared.signOut { didSignOut in
                    if didSignOut {
                        guard let topVC = topViewController
                        else { return }

                        let signInVC = SignInViewController()
                        let navVC    = UINavigationController(rootViewController: signInVC)
                        navVC.modalPresentationStyle = .fullScreen
                        
                        topVC.present(navVC, animated: true)
                        topVC.navigationController?.popToRootViewController(animated: true)
                        topVC.tabBarController?.selectedIndex = 0
                    } else {
                        // failed
                        SCLAlertView().showError("Woops",subTitle: "Something went wrong when signing out. Please try again.")
                    }
                }
            }
}
