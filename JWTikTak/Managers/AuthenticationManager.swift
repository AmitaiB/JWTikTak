//
//  AuthenticationManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseAuth

typealias AuthDataResultCompletion  = ((Result<AuthDataResult, Error>) -> Void)
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
        case userCreationFailed
    }
    
    // Public
    public var isSignedIn: Bool { Auth.auth().currentUser != nil }
    
    /// Signs in using an email address and password.
    public func signIn(withEmail email: String,
                       password: String,
                       completion: @escaping AuthEmailResultCompletion) {
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
    
    public func signUp(
        withUsername username: String,
        email: String,
        password: String,
        completion: @escaping AuthEmailResultCompletion
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.handleUserCreation(forUsername: username,
                                    email: email,
                                    withResult: result,
                                    error: error,
                                    completion: completion)
        }
        
    }
    
    private func handleUserCreation(
        forUsername username: String,
        email: String,
        withResult result: AuthDataResult?,
        error: Error?,
        completion: @escaping AuthEmailResultCompletion
    ) {
        switch (result, error) {
                // Firebase reported an error.
                // TODO: Check for username availability before attempting creation?
            case (_, .some(let firebaseError)):
                completion(.failure(firebaseError))
                // No firebase response = app-level error
            case (.none, _):
                completion(.failure(AuthError.userCreationFailed))
                // Happy path, if successful (user creation + sign in) -> register user in db.
            case (.some, .none):
                DatabaseManager.shared.insertUser(
                    withEmail: email,
                    username: username,
                    completion: { dbResult in
                        switch dbResult {
                            case .success(_):
                            // discard the dbRef, report success if no Auth or Firebase errors
                                completion(.success(email))
                            case .failure(let dbEerror):
                                completion(.failure(dbEerror))
                        }
                    }
                )
        }
    }
}
