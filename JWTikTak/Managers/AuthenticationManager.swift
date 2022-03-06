//
//  AuthenticationManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseAuth

typealias AuthDataResultCompletion = ((Result<AuthDataResult, Error>) -> Void)
typealias AuthEmailResultCompletion = ((Result<String, Error>) -> Void)

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
    
    enum AuthError: Error {
        case signInFailed
    }
    
    // Public
    public var isSignedIn: Bool { Auth.auth().currentUser != nil }
    
    /// Signs in using an email address and password.
    public func signIn(withEmail email: String, password: String, completion: @escaping AuthEmailResultCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            switch (result, error) {
                    // Happy path, successful sign in.
                case (.some, .none):
                    completion(.success(email))
                    // Firebase reported an error.
                case (_, .some(let firebaseError)):
                    completion(.failure(firebaseError))
                    // No firebase response = app-level error
                case (.none, _):
                    completion(.failure(AuthError.signInFailed))
            }
        }
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
