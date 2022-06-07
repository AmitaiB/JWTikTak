//
//  AuthenticationManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseAuth

// NOTE: DbManager and AuthManager are tightly coupled!
typealias AuthDataResultCompletion   = ((Result<AuthDataResult, Error>) -> Void)
typealias AuthStringResultCompletion = ((Result<String, Error>) -> Void)
typealias UserResultCompletion       = ((Result<User, Error>) -> Void)

/// Encapsulates authentication logic. Handles `FIRUser`, does not own `User` (and therefore, not `username`.
final class AuthManager {
    // Singleton
    public static let shared = AuthManager()
    private init() {
        authStateListner = Auth.auth().addStateDidChangeListener(
            { _, currentUser in
                NotificationCenter.default
                    .post(name: .authStateDidChange, object: currentUser)
            }
        )
    }

    
    private var authStateListner: AuthStateDidChangeListenerHandle?
    // TODO: Remove, use Notifications instead of calling db methods here.
    private weak var database = DatabaseManager.shared
    
    enum SignInMethod {
        case email
        case google
        case facebook
    }
    
    // Public
    public var isSignedIn: Bool { Auth.auth().currentUser != nil }
    
    /// Signs in using an email address and password.
    public func signIn(withEmail email: String,
                       password: String,
                       completion: @escaping AuthStringResultCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            switch (result, error) {
                    // Firebase reported an error.
                case (_, .some(let firebaseError)):
                    completion(.failure(firebaseError))

                    // No firebase response = app-level error
                case (.none, _):
                    completion(.failure(AuthError.signInFailed))

//                     Happy path, successful sign in
                case (.some, .none):
                    completion(.success(email))
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
    
    // Called by the user tapping "Sign Up"
    public func signUp(
        withUsername username: String,
        email: String,
        password: String,
        completion: @escaping AuthStringResultCompletion
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            // retrieve the new user's uid, then make a new User with email, password, displayname, and UID.
            self.handleUserCreation(forUsername: username,
                                    email: email,
                                    withResult: result,
                                    error: error,
                                    completion: completion)
        }
    }
    
    
    // MARK: - Helper methods
            
    private func handleUserCreation(
        forUsername newUsername: String,
        email: String,
        withResult result: AuthDataResult?,
        error: Error?,
        completion: @escaping AuthStringResultCompletion
    ) {
        switch (result, error) {
                // Firebase server reported an error.
                // TODO: Check for username availability before attempting creation?
            case (_, .some(let firebaseError)):
                completion(.failure(firebaseError))

                // No firebase response = local, 'app-level' error
            case (.none, _):
                completion(.failure(AuthError.userCreationFailed))

                // Happy path: successful user creation (also signs in).
                // Now: (1) create a User object and insert it into the db, and
                // (2) trigger the sign in flow.
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
    ///   - firUser: The object created by FIR servers, including its User UID.
    ///   - newUsername: aka, the `displayName`
    ///   - completion: Passes along the username to indicate success in the UI.
    private func handleSuccessfulUserCreation(ofNewUser firUser: FIRUser,
                                              withUsername newUsername: String,
                                              completion: @escaping AuthStringResultCompletion) {
        let newUser = User(identifier: firUser.uid,
                           email: firUser.email,
                           displayName: firUser.displayName ?? newUsername,
                           profilePictureURL: firUser.photoURL
        )
        
        database?.insert(user: newUser) { [weak self] dbResult in
            switch dbResult {
                case .success(_):
                    // discard the dbRef, report success if no Auth or Firebase errors
                    completion(.success(newUser.displayString))
                    // and save the user locally
                    self?.database?.updateCachedUser(with: newUser)
                    
                case .failure(let dbEerror):
                    completion(.failure(dbEerror))
            }
        }
    }
}
