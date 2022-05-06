//
//  AuthenticationManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseAuth

// NOTE: DbManager and AuthManager are tightly coupled!
typealias AuthDataResultCompletion  = ((Result<AuthDataResult, Error>) -> Void)
typealias AuthEmailResultCompletion = ((Result<String, Error>) -> Void)

/// Encapsulates authentication logic. Handles `FIRUser`, does not own `User` (and therefore, not `username`.
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
            DatabaseManager.shared.updateCachedUserWith(username: .none)
            completion(true)
        }
        catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    // Called by the user tapping "Sign Up"
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
                DatabaseManager.shared.updateCachedUserWith(username: username)
                print("Got username: \(username)")
            case .failure(let error):
                print(error.localizedDescription)
        }
    }
    
    private func handleUserCreation(
        forUsername newUsername: String,
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
            case (.some(let result), .none):
                self.handleSuccessfulUserCreation(
                    ofNewUser: result.user,
                    withUsername: newUsername,
                    completion: completion
                )
        }
    }
    
    /// The new `user` in the FIRAuth Db now needs to be stored in Realtime Db for business logic use.
    /// - Parameters:
    ///   - authId: The `FIRUserInfo.uid` string assigned by the FIRAuth server on User creation.
    private func handleSuccessfulUserCreation(ofNewUser user: FIRUser,
                                              withUsername newUsername: String,
                                              completion: @escaping AuthEmailResultCompletion) {
        database?.insert(newUser: user,
                         withUsername: newUsername,
                         completion: { dbResult in
            switch dbResult {
                case .success(_):
                    // discard the dbRef, report success if no Auth or Firebase errors
                    completion(.success(user.email ?? "??@??.??"))
                    // and save the username locally
                    DatabaseManager.shared.updateCachedUserWith(username: newUsername)
                case .failure(let dbEerror):
                    completion(.failure(dbEerror))
            }
        }
        )
    }
}
