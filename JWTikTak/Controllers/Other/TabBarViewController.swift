//
//  TabBarViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import SwiftUI

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSignInIfNeeded()
    }
    
    private func presentSignInIfNeeded() {
        guard !AuthManager.shared.isSignedIn else { return }
        let signInVC = SignInViewController()
        let navVC = UINavigationController(rootViewController: signInVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false, completion: nil)
    }
    
    
    private func setupControllers() {
        let homeVC          = HomeViewController()
        let exploreVC       = ExploreViewController()
        let cameraVC        = CameraViewController()
        let notificationsVC = NotificationsViewController()
        let profileVC       = ProfileViewController(user: User(username: "Rando", profilePictureURL: nil, identifier: "GET A NEW ONE"))
        
        // The camera VC does not need a title, and home VC has a control in that place.
        exploreVC.title       = L10n.explore
        notificationsVC.title = L10n.notifications
        profileVC.title       = L10n.profile
        
        let homeNav          = UINavigationController(rootViewController: homeVC)
        let exploreNav       = UINavigationController(rootViewController: exploreVC)
        // The camera VC does not need a navigation controller
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        let profileNav       = UINavigationController(rootViewController: profileVC)
        
        // Allows the Following/ForYou control to 'float'
        homeNav.navigationBar.backgroundColor = .clear
        homeNav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        homeNav.navigationBar.shadowImage = UIImage()
        
        homeNav.tabBarItem          = UITabBarItem(title: nil, image:  UIImage(systemName: L10n.SFSymbol.house), selectedImage: nil)
        exploreNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.magnifyingglass), selectedImage: nil)
        cameraVC.tabBarItem         = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.camera), selectedImage: nil)
        notificationsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.bell), selectedImage: nil)
        profileNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.personCircle), selectedImage: nil)
        
        setViewControllers([homeNav, exploreNav, cameraVC, notificationsNav, profileNav], animated: false)
    }
    
}
