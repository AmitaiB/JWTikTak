//
//  Firebase+Extensions.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/2/22.
//

import Foundation
import Firebase

/// `FirebaseAuth.User` alias, to avoid conflict with `JWTikTak.User`.
typealias FIRUser = FirebaseAuth.User

extension NSNotification.Name {
    
    ///  Fires when AuthManager is initialized, when a user with a different UID from the current user has signed in, or when the current user has signed out.
    static let FIRAuthStateDidChange = NSNotification.Name(L10n.NotificationName.firAuthStateDidChange)
    static let DatabaseManagerDidUpdateCurrentUser = NSNotification.Name(
        L10n.NotificationName.databaseManagerDidUpdateCurrentUser)
}
