//
//  TabBarViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import SwiftUI

class TabBarViewController: UITabBarController {

    private var signInHasBeenPresented = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
        setupAuthObserver()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSignInIfNeeded()
    }
    
    // TODO: Expose this to the AuthenticationManager via a delegate method.
    private func presentSignInIfNeeded() {
        guard !AuthManager.shared.isSignedIn else { return }
        let signInNavVC = UINavigationController(rootViewController: SignInViewController())
        signInNavVC.modalPresentationStyle = .fullScreen
        present(signInNavVC, animated: false, completion: nil)
    }
    
    private func setupControllers() {
        let homeVC          = HomeViewController()
        let exploreVC       = ExploreViewController()
        let cameraVC        = CameraViewController()
        let notificationsVC = NotificationsViewController()
        let mockProfileVC = ProfileViewController(userId: L10n.UserUID.johnDoe)
        let profileVC       = ProfileViewController(
            userId: DatabaseManager.shared.currentUser?.identifier ?? User.empty.identifier
        )
        
        let homeNav          = UINavigationController(rootViewController: homeVC)
        let exploreNav       = UINavigationController(rootViewController: exploreVC)
        let cameraNav        = UINavigationController(rootViewController: cameraVC)
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        let profileNav       = UINavigationController(rootViewController: mockProfileVC)

        // The camera VC does not need a title, and home VC has a control in that place.
        exploreVC.title       = L10n.explore
        notificationsVC.title = L10n.notifications
        profileVC.title       = L10n.profile
        
        // Misc UI configurations.
        configureTransparentNavbar(for: homeNav, cameraNav)
        cameraNav.navigationBar.tintColor = .white
        // TODO: Fix the text colors, add text border
        notificationsNav.navigationBar.tintColor = .label
//        UINavigationBar.appearance().backItem?.backButtonDisplayMode = .minimal
        
        // Set each tab's image, and navbar settings.
        [
            homeNav     : L10n.SFSymbol.house,
            exploreNav  : L10n.SFSymbol.magnifyingglass,
            cameraNav   : L10n.SFSymbol.camera,
            notificationsNav: L10n.SFSymbol.bell,
            profileNav  : L10n.SFSymbol.personCircle,
        ]
            .forEach { nav, imageName in
                nav.tabBarItem = UITabBarItem(
                    title: nil,
                    image: UIImage(systemName: imageName),
                    selectedImage: nil)
            }

        // Set each tab's VC.
        setViewControllers([homeNav,
                            exploreNav,
                            cameraNav,
                            notificationsNav,
                            profileNav],
                           animated: false)
    }
    
    private func setupAuthObserver() {
        NotificationCenter.default
            .add(observer: self, name: .didUpdateCurrentUser) { [weak self] in
                self?.handleAuthStateUpdate(newCurrentUser: $0.object as? User)
        }
    }
    
    private func handleAuthStateUpdate(newCurrentUser: User?) {
        newCurrentUser.ifNone { self.presentSignInIfNeeded() }
        newCurrentUser.ifSome {
            (viewControllers as? [UINavigationController])?
                .compactMap( {$0.topViewController as? ProfileViewController} )
                .first?.configure(with: $0)
        }
    }
    
    // Allows title bar controls (like "following/for you") to 'float'
    private func configureTransparentNavbar(for navControllers: UINavigationController...) {
        navControllers.forEach {
            $0.navigationBar.backgroundColor = .clear
            $0.navigationBar.setBackgroundImage(UIImage(), for: .default)
            $0.navigationBar.shadowImage     = UIImage()
        }
    }
}
