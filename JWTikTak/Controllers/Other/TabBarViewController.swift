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
        
        homeVC.title          = "Home"
        exploreVC.title       = "Explore"
        // The camera VC does not need a title
        notificationsVC.title = "Notifications"
        profileVC.title       = "Profile"
        
        let homeNav          = UINavigationController(rootViewController: homeVC)
        let exploreNav       = UINavigationController(rootViewController: exploreVC)
        // The camera VC does not need a navigation controller
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        let profileNav       = UINavigationController(rootViewController: profileVC)
        
        homeNav.tabBarItem          = UITabBarItem(title: nil, image:  UIImage(systemName: "house"), selectedImage: nil)
        exploreNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)
        cameraVC.tabBarItem         = UITabBarItem(title: nil, image: UIImage(systemName: "camera"), selectedImage: nil)
        notificationsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bell"), selectedImage: nil)
        profileNav.tabBarItem       = UITabBarItem(title: nil, image: UIImage(systemName: "person.circle"), selectedImage: nil)
        
        setViewControllers([homeNav, exploreNav, cameraVC, notificationsNav, profileNav], animated: false)
    }
    
}
