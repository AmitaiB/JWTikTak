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
    
    private weak var database = DatabaseManager.shared
    
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
    public var currentUsername: String? { _currentUsername }
    
    /// Signs in using an email address and password.
    public func signIn(withEmail email: String,
                       password: String,
                       completion: @escaping AuthEmailResultCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            switch (result, error) {
                    // Firebase reported an error.
                case (_, .some(let firebaseError)):
                    completion(.failure(firebaseError))

                    // No firebase response = app-level error
                case (.none, _):
                    completion(.failure(AuthError.signInFailed))

                    // Happy path, successful sign in —> also save username in memory
                case (.some, .none):
                    completion(.success(email))
                    self.database?.getUsername(
                        for: email,
                        completion: self.handleUsernameFetch
                    )
            }
        }
    }
        
    public func signOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            _currentUsername = nil
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
    
    
    // MARK: - Helper methods
    
    private let handleUsernameFetch: (Result<String, Error>) -> Void = {
        switch $0 {
            case .success(let username):
                _currentUsername = username
                print("Got username: \(username)")
            case .failure(let error):
                print(error.localizedDescription)
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

                // Happy path, if successful (user creation + sign in) -> register user in db
                // and save the username locally
            case (.some, .none):
                self.handleSuccessfulUserCreationAttempt(
                    email: email,
                    username: username,
                    completion: completion
                )
        }
    }
    
    private func handleSuccessfulUserCreationAttempt(email: String,
                                 username: String,
                                 completion: @escaping AuthEmailResultCompletion) {
        database?.insertUser(
            withEmail: email,
            username: username,
            completion: { dbResult in
                switch dbResult {
                    case .success(_):
                        // discard the dbRef, report success if no Auth or Firebase errors
                        completion(.success(email))
                        // and save the username locally
                        _currentUsername = username
                    case .failure(let dbEerror):
                        completion(.failure(dbEerror))
                }
            }
        )
    }
}

// Workaround to allow for cleaner code blocks in this file.
fileprivate var _currentUsername: String? {
    set { UserDefaults.standard.set(newValue, forKey: L10n.Key.username) }
    get { UserDefaults.standard.string(forKey: L10n.Key.username) }
}
