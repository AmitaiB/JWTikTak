//
//  Notification.Name+Extensions.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 6/7/22.
//

import Foundation

extension NSNotification.Name {
    
    ///  Fires when AuthManager is initialized, when a user with a different UID from the current user has signed in, or when the current user has signed out.
    static let authStateDidChange = NSNotification.Name(
        L10n.NotificationName.AuthManager.authStateDidChange)
    static let didUpdateCurrentUser = NSNotification.Name(
        L10n.NotificationName.DatabaseManager.didUpdateCurrentUser)
    static let didAddNewPost = NSNotification.Name(
        L10n.NotificationName.DatabaseManager.didAddNewPost)
}
