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
    
    private func setupControllers() {
        let homeVC          = HomeViewController()
        let exploreVC       = ExploreViewController()
        let cameraVC        = CameraViewController()
        let notificationsVC = NotificationsViewController()
        let profileVC       = ProfileViewController()
        
        // This default may be overwritten by the "following/forYou" control.
        homeVC.title          = L10n.home
        exploreVC.title       = L10n.explore
        // The camera VC does not need a title
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
        
        homeNav.tabBarItem          = UITabBarItem(title: nil, image:  UIImage(systemName: L10n.SFSymbol.home), selectedImage: nil)
        exploreNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.explore), selectedImage: nil)
        cameraVC.tabBarItem         = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.camera), selectedImage: nil)
        notificationsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.notification), selectedImage: nil)
        profileNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: L10n.SFSymbol.profile), selectedImage: nil)
        
        setViewControllers([homeNav, exploreNav, cameraVC, notificationsNav, profileNav], animated: false)
    }
    
}
