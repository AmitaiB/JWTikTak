//
//  AuthenticationManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseAuth

// FIXME: DbManager and AuthManager are tightly coupled!
typealias StringResultCompletion = (Result<String, Error>) -> Void
typealias UserResultCompletion   = (Result<User, Error>) -> Void

/// Encapsulates authentication logic.
/// - note: As a general rule, handles `FIRUser`; whereas `DatabaseManager` is in charge of `User`s.
final class AuthManager {
    // Singleton
    /// Returns the shared authentication manager instance.
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
    
    // Public
    /// Synchronously checks for a cached current user (`FIRUser`).
    public var isSignedIn: Bool { Auth.auth().currentUser != nil }
    
    
    /// Signs in using an email address and password.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - completion: The completion handler to call when the sign in task is complete; it passes a `Result` that either wraps a `String` object on success, or an error on failure.
    public func signIn(withEmail email: String,
                       password: String,
                       completion: @escaping StringResultCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            switch (result, error) {
                    // Firebase reported an error.
                case (_, .some(let firebaseError)):
                    completion(.failure(firebaseError))

                    // No firebase response = app-level error
                case (.none, _):
                    completion(.failure(AuthError.signInFailed))

                    // Happy path, successful sign in
                case (.some, .none):
                    completion(.success(email))
            }
        }
    }
    
    /// Signs out the current user.
    /// - Parameter completion: The completion handler to call when the sign out task is complete; it passes a `Bool` indicating success (`true`) or failure (`false`).
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
    
    /// Creates and, on success, signs in a user with the given email address and password.
    /// - Parameters:
    ///   - username: The username to associate with the new user account.
    ///   - email: The email address to associate with the new user account.
    ///   - password: The password for the new user account.
    ///   - completion: The completion handler to call when the new sign up task is complete; it passes a `Result` that either wraps a `String` object on success, or an error on failure.
    public func signUp(
        withUsername username: String,
        email: String,
        password: String,
        completion: @escaping StringResultCompletion
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
    
    /// Route the response to the attempted user creation between the happy path or error handling.
    private func handleUserCreation(
        forUsername newUsername: String,
        email: String,
        withResult result: AuthDataResult?,
        error: Error?,
        completion: @escaping StringResultCompletion
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
    
    /// Retrieves the new user's FIRAuth-server-generated uid to complete the new `User` object,
    /// which then needs to be stored in the FIR Realtime Db so as to share/expose it to the app's
    /// business logic flow.
    /// - Parameters:
    ///   - firUser: The object created by the FIR Auth server, including its User UID, which is adopted as the `User`'s UID as well.
    ///   - newUsername: Not intended to be a primary key; that is, this is 'merely' a `displayName`.
    ///   - completion: The completion handler to call when the new sign up task is complete; it passes a `Result` that either wraps a `String` object (cotaining the username) on success, or an error on failure.
    private func handleSuccessfulUserCreation(ofNewUser firUser: FIRUser,
                                              withUsername newUsername: String,
                                              completion: @escaping StringResultCompletion) {
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
