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
    
    public func signIn(with method: SignInMethod) {
        
    }
    
    public func signOut() {
        
    }
}
