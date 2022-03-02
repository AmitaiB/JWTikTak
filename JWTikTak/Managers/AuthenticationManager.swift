//
//  AuthenticationManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseAuth

/// Encapsulates authentication logic.
final class AuthManager {
    // Singleton
    public static let shared = AuthManager()
    private init() {}
    
    enum SignInMethod {
        case email
        case google
        case facebook
    }
    
    // Public
    public var isSignedIn: Bool { Auth.auth().currentUser != nil }
    
    
    public func signIn(with method: SignInMethod) {
        
    }
    
    public func signOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        }
        catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
}
