//
//  AppDelegate.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/8/22.
//

import UIKit
import Firebase
import JWPlayerKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = TabBarViewController()
        self.window = window
        self.window?.makeKeyAndVisible()
        
        
#warning("Make sure the JWPlayer license key is set.")
        JWPlayerKitLicense.setLicenseKey(Secure.jwplayerKey)
        
        setAudioSessionToMoviePlaybackMode()
        
        return true
    }
    
    private func setAudioSessionToMoviePlaybackMode() {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(.playback, mode: .moviePlayback, options: [])
            
            try AVAudioSession.sharedInstance()
                .setActive(true, options: [])
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

