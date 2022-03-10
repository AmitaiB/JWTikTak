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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if !signInHasBeenPresented {
            presentSignInIfNeeded()
//        }
    }
    
    private func presentSignInIfNeeded() {
        guard !AuthManager.shared.isSignedIn else { return }
//        signInHasBeenPresented = true
        let signInVC = SignInViewController()
//        signInVC.viewControllerCompletion = { [weak self] in
//            // resets
//            self?.signInHasBeenPresented = false
//        }
        let navVC = UINavigationController(rootViewController: signInVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false, completion: nil)
    }
    
    
    private func setupControllers() {
        let homeVC          = HomeViewController()
        let exploreVC       = ExploreViewController()
        let cameraVC        = CameraViewController()
        let notificationsVC = NotificationsViewController()
        let profileVC       = ProfileViewController(user: User.mock)
        
        // The camera VC does not need a title, and home VC has a control in that place.
        exploreVC.title       = L10n.explore
        notificationsVC.title = L10n.notifications
        profileVC.title       = L10n.profile
        
        let homeNav          = UINavigationController(rootViewController: homeVC)
        let exploreNav       = UINavigationController(rootViewController: exploreVC)
        let cameraNav        = UINavigationController(rootViewController: cameraVC)
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        let profileNav       = UINavigationController(rootViewController: profileVC)
        
        
        configureTransparentNavbar(for: homeNav, cameraNav)
        
        homeNav.tabBarItem          = UITabBarItem(title: nil, image:  UIImage(systemName: L10n.SFSymbol.house), selectedImage: nil)
        exploreNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.magnifyingglass), selectedImage: nil)
        cameraNav.tabBarItem         = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.camera), selectedImage: nil)
        notificationsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.bell), selectedImage: nil)
        profileNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.personCircle), selectedImage: nil)
        
        setViewControllers([homeNav,
                            exploreNav,
                            cameraNav,
                            notificationsNav,
                            profileNav],
                           animated: false)
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
