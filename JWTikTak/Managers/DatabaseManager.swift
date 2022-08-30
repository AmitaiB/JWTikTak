//
//  DatabaseManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseDatabase
import CodableFirebase
import FirebaseAuth
import Actions

typealias UserDictionary = [String: User]
typealias PostDictionary = [String: PostModel]
/// Alias for FIR Realtime Database reference often returned by FIR Db operations.
typealias DatabaseRefResultCompletion = (Result<DatabaseReference, Error>) -> Void

/// The Firebase db manager (for 'spreadsheet' data, such as users etc.).
final class DatabaseManager: NSObject {
    // Singleton
    /// Returns the shared database manager instance.
    public static let shared = DatabaseManager()
    private override init() {
        super.init()
        // TODO: replace Actions with UIActions
        NotificationCenter.default
            .add(observer: self, name: .authStateDidChange) { [weak self] in
                self?.handleAuthStateUpdate(possibleFIRUser: $0.object)
            }
        
        refreshCurrentUserIfNeeded()
    }
        
    /// The root of the Firebase Database instance on which the manager's other methods operate.
    private let database = Database.database().reference()

    /// The `JWTikTak.User` representing the current user logged into the app (locally).
    /// - note: Posts a notification when updated.
    /// - returns: `nil` if logged out.
    private(set) var currentUser: User? {
        didSet {
            NotificationCenter.default
                .post(name: .didUpdateCurrentUser, object: currentUser)
        }
    }
    
    // Should be called on startup and on signing in/out
    
    /// Retrieves the `User` from the FIR Realtime Db using the `FIRUser`'s UID as key and/or responds
    /// to logging out.
    /// - Parameter object: The currently logged in `FIRUser`, or `nil` if logged out.
    private func handleAuthStateUpdate(possibleFIRUser object: Any?) {
        // nil user indicates signed out
        guard let firUser = object as? FIRUser
        else {
            updateCachedUser(with: .none)
            return
        }
        
        getUser(withId: firUser.uid) { [weak self] result in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let user):
                    self?.updateCachedUser(with: user)
            }
        }
    }
    
    /// Updates the internally tracked `currentUser` in the `DatabaseManager`.
    /// - Parameter user: The currently logged in `User`, or `nil` if logged out.
    public func updateCachedUser(with user: User?) {
        currentUser = user
    }
    
    /// Use to update any `User` value except for the primary key (the `identifier` property).
    /// - note: While this method is non-destructive (passing a `nil` value will not delete the property),
    /// the decision depends on the sync strategy.
    /// - Parameters:
    ///   - shouldSync: After updating the local value, will update those values on the server.
    public func updateUserValues(newEmail: String?                 = nil,
                                       newDisplayName: String?     = nil,
                                       newProfilePicURL: URL?      = nil,
                                       newOwnedPosts: [String]?    = nil,
                                       newUsername: String?        = nil,
                                       newFollowerIds: [String]?   = nil,
                                       newFollowingIds: [String]?  = nil,
                                       shouldSyncWithServer: Bool  = false
    ) {
        newEmail        .ifSome { currentUser?.email             = $0 }
        newDisplayName  .ifSome { currentUser?.displayName       = $0 }
        newProfilePicURL.ifSome { currentUser?.profilePictureURL = $0 }
        newOwnedPosts   .ifSome { currentUser?.ownedPosts        = $0 }
        newUsername     .ifSome { currentUser?.username          = $0 }
        newFollowerIds  .ifSome { currentUser?.followers         = $0 }
        newFollowingIds .ifSome { currentUser?.following         = $0 }
        
        if shouldSyncWithServer {
            syncCurrentUser(withStrategy: .ours)
        }
    }
    
    // TODO: Add `.merge` strategy?
    
    /// A strategy with which to synchronize the server with the local values.
    enum SyncStrategy {
        /// Overwrites the server with the local version.
        case ours
        /// Overwrites the local version with the server's version.
        case theirs
    }
    
    /// Synchronizes the local values with the server's, in the case where values have been
    /// changed locally by the user, or the local models need to be populated by the server.
    /// - Parameter strategy: The strategy with which to synchronize the server with the local values.
    public func syncCurrentUser(withStrategy strategy: SyncStrategy = .ours) {
        guard let currentUser = currentUser
        else { return }

        switch strategy {
            case .ours:
                insert(user: currentUser) { _ in }
            case .theirs:
                // download theirs, set to currentUser
                getUser(withId: currentUser.identifier) { [weak self] result in
                    switch result {
                        case .failure(let error):
                            print(error)
                        case .success(let downloadedUser):
                            self?.currentUser = downloadedUser
                    }
                }
        }
    }
    
    // Public

    /// Adds the new user to the FIR Realtime database.
    /// - Parameters:
    ///   - user: A `User` representing the user to add.
    ///   - completion: The completion handler to call when the upload task is complete; it passes a `Result` that
    ///   wraps either a `FIRDatabaseReference` on success, or an error on failure.
    public func insert(user: UserModel,
                       completion: @escaping DatabaseRefResultCompletion
    ) {
        let userData = try! FirebaseEncoder().encode(user)
        let path = L10n.Fir.userWithId(user.identifier)
        
        database.child(path).setValue(
            userData,
            withCompletionBlock: dbSetValueCompletion(withItsOwn: completion))
    }
    
    /// Retrieves the `User` given its `identifier` from the FIR Realtime Db.
    /// - Parameters:
    ///   - identifier: The user's UID, which is set to the `FIRUser`'s UID on account creation.
    ///   - completion: The completion handler to call when the fetch is complete; it passes a `Result`
    ///    that either wraps the requested `User` object on success, or an error on failure.
    public func getUser(withId identifier: String, completion: @escaping UserResultCompletion) {
        let path = L10n.Fir.userWithId(identifier)
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                let error = DatabaseError.fetchedValueNil(line: "line: \(#line)")
                completion(.failure(error))
                return
            }
            
            guard let resultUser = try? FirebaseDecoder().decode(User.self, from: value)
            else { return }
            completion(.success(resultUser))
        }
    }
    
    // TODO: Unused. Remove, or expand functionality.
    /// Retrieves the `User` given its email address.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - completion: The completion handler to call when the fetch is complete; it passes a `Result`
    ///    that either wraps the requested `User` object on success, or an error on failure.
    public func getUser(for email: String, completion: @escaping UserResultCompletion) {
        database.child(L10n.Fir.users)
            .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value
                else {
                    let error = DatabaseError.fetchedValueNil(line: "line: \(#line)")
                    completion(.failure(error))
                    return
                }
                
                do {
                    let usersDict = try FirebaseDecoder().decode(UserDictionary.self,
                                                                 from: value)
                    // pass the matching user to the handler
                    usersDict
                        .values
                        .first(where: {email == $0.email})
                        .ifSome { completion(.success($0)) }
                    
                } catch { print(error.localizedDescription) }
            }
    }
    
    /// Records the new `Post` in storage.
    ///
    /// FIR RealtimeDb has a flat hierarchy, so full `Post`s are stored in their own root directory, with `User`s retaining a collection of references to their associated `Posts`. Both locations need to be updated respectively.
    /// - Parameters:
    ///   - newPost: The model representing the user's newly created post.
    ///   - completion: The completion handler to call when the upload task is complete; it passes a `Result` that
    ///   wraps either a `FIRDatabaseReference` on success, or an error on failure.
    public func insert(newPost: PostModel, completion: @escaping DatabaseRefResultCompletion) {
        // TODO: See if this can be condensed to one call, using `updateChildValues`: https://firebase.google.com/docs/database/ios/read-and-write#update_specific_fields
        updateRootArrayOfPosts(with: newPost, completion: completion)
        updateCurrentUserListOfPostsIDs(with: newPost, completion: completion)
    }
    
    /// Records the full `PostModel` in storage with all other posts. Helps `insert(newPost:)`.
    private func updateRootArrayOfPosts(with newPost: PostModel, completion: @escaping DatabaseRefResultCompletion) {
        let newPostData = try? FirebaseEncoder().encode(newPost)
        let postsDbRef  = database.child(L10n.Fir.postWithId(newPost.identifier))
        postsDbRef.setValue(newPostData,
                            withCompletionBlock: dbSetValueCompletion(withItsOwn: completion)
        )
    }

    /// Updates the `currentUser`'s collection of associated posts with the new post. Helps `insert(newPost:)`.
    private func updateCurrentUserListOfPostsIDs(with newPost: PostModel, completion: @escaping DatabaseRefResultCompletion) {
        guard let uid = currentUser?.identifier else {
            completion(.failure(DatabaseError.cachedUserUidNil))
            return
        }
        
        // TODO: Use L10n.fir.userWithId
        let userDbRef = database.child(L10n.Fir.users).child(uid)
        
        userDbRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                let error = DatabaseError.fetchedValueNil(line: "line: \(#line)")
                completion(.failure(error))
                return
            }
            
            do {
                // decode -> update local obj -> encode -> update remote db
                var user = try FirebaseDecoder().decode(User.self, from: value)
                user.ownedPosts.coalescingAppend(newPost.identifier)
                let updatedUserData = try FirebaseEncoder().encode(user)
                userDbRef.setValue(updatedUserData,
                                   withCompletionBlock: dbSetValueCompletion(withItsOwn: completion)
                )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Updates the given user's list of the given relationship type.
    ///
    /// - note: A new relationship needs to be recorded by both "sides", so this will be called twice.
    /// - Parameters:
    ///   - user: The `User` model representing the user to update.
    ///   - userIdsToInsert: The unique user id's to **add** to the user's recognized relationships (of the chosen type).
    ///   - userIdsToRemove: The unique user id's to **remove** to the user's recognized relationships (of the chosen type).
    ///   - followType: Currently, `followers` or `following` only.
    ///   - completion: The completion handler to call when the update task is complete; it passes a `Result` that either wraps a `FIRDatabaseReference` object on success, or an error on failure.
    public func updateListOfFollowIDs(
        for user: User,
        inserting userIdsToInsert:[String] = [],
        removing userIdsToRemove: [String] = [],
        ofType followType: FollowRelationType,
        completion: @escaping DatabaseRefResultCompletion)
    {
        let path = L10n.Fir.userWithId(user.identifier)
        database.child(path).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let value = snapshot.value else {
                let error = DatabaseError.fetchedValueNil(line: "line: \(#line)")
                completion(.failure(error))
                return
            }
            
            do {
                // decode -> update local obj -> encode -> update remote db
                var user = try FirebaseDecoder().decode(User.self, from: value)
                
                switch followType {
                    case .following:
                        user.following?.removeAll(where: {userIdsToRemove.contains($0)} )
                        user.following.coalescingAppend(contentsOf: userIdsToInsert)
                    case .followers:
                        user.followers?.removeAll(where: {userIdsToRemove.contains($0)} )
                        user.followers.coalescingAppend(contentsOf: userIdsToInsert)
                }
                
                let updatedUserData = try FirebaseEncoder().encode(user)
                self?.database.child(path)
                    .setValue(updatedUserData,
                              withCompletionBlock: dbSetValueCompletion(
                                withItsOwn: completion)
                    )
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    /// A convenience method that calls `updateListOfFollowIDs(...)` for the `currentUser`.
    public func updateCurrentUserListOfFollowIDs(
        adding userIdsToInsert:   [String] = [],
        removing userIdsToRemove: [String] = [],
        ofType followType: FollowRelationType,
        completion: @escaping DatabaseRefResultCompletion)
    {
        guard let currentUser = currentUser else {
            completion(.failure(DatabaseError.cachedUserUidNil))
            return
        }

        updateListOfFollowIDs(for: currentUser,
                              inserting: userIdsToInsert,
                              removing: userIdsToRemove,
                              ofType: followType,
                              completion: completion
        )
    }
    
    /// Synchronizes the local `currentUser` with the FirebaseAuth logged in `FIRUser`.
    ///
    /// As there is no guarantee that the `DatabaseManager` will exist at the time that the `AuthManager`
    /// posts its notification about the state of the `currentUser`, this method is called to guarantee that they are in sync.
    private func refreshCurrentUserIfNeeded() {
        let currentUserNeedsRefresh = Auth.auth().currentUser.isSome && currentUser.isNone
        
        if currentUserNeedsRefresh {
            handleAuthStateUpdate(possibleFIRUser: Auth.auth().currentUser)
        }
    }
        
    
    
    // MARK: - Notifications
    
    /// Retrieves the notifications associated with the `currentUser`.
    /// - Parameter completion: The completion handler to call when the fetch is complete; it passes a `Result` that
    ///   wraps either an array of `Notification`s on success, or an error on failure.
    public func getNotifications(completion: @escaping (Result<[Notification], Error>) -> Void) {
        completion(.success(Notification.mockData()))
    }
    
    // TODO: replace the (Bool) -> Voids with Result<User, Error> or whatnot.
    // TODO: TODO: Replace completion blocks with await/async!
    public func markNotificationAsHidden(withId id: String, completion: @escaping (Bool) -> Void) {
#warning("function is not implemented!")
#if DEBUG
        completion(true)
#endif
    }

    
    // TODO: - implement as per the warning below
    /// Updates the user...to follow
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - completion: <#completion description#>
    public func follow(username: String, completion: @escaping (Result<User, Error>) -> Void) {
#warning("function is not implemented! Get the ID from the username or get the id directly, and then update the follow IDs calling the above functions")
#if DEBUG
        completion(.success(User(identifier: "fake user ID", username: username)))
#endif
    }

    
    // MARK: - Posts
    
    /// Retrieves the posts associated with the given user.
    /// - Parameters:
    ///   - user: The `User` model representing the user whose posts are being fetched.
    ///   - completion: The completion handler to call when the fetch is complete; it passes a `Result` that
    ///   wraps either an array of `PostModel`s on success, or an error on failure.
    public func getPosts(for user: User, completion: @escaping (Result<[PostModel], Error>) -> Void) {
        database.child(L10n.Fir.posts)
            .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value
                else {
                    let error = DatabaseError.fetchedValueNil(line: "line: \(#line)")
                    completion(.failure(error))
                    return
                }
                
                do {
                    let postsDict = try FirebaseDecoder().decode(PostDictionary.self,
                                                                 from: value)
                    let userPosts: [PostModel] = postsDict
                        .values
                        .filter({(user.ownedPosts ?? []).contains($0.identifier)})
                        .sorted()
                    
                    completion(.success(userPosts))
                } catch { print(error.localizedDescription) }
            }
    }
    
    /// Determines whether the relationship to the `currentUser` of the selected type is valid.
    /// - note: In logical terms (as per the database), "Is the target user amongst the current user's collection of {relationship}?"
    /// - Parameters:
    ///   - user: Target user to check against the `currentUser`.
    ///   - type: Currently, `followers` or `following` only.
    ///   - completion: The completion handler to call when the fetch is complete; it passes a `Result` that
    ///   wraps either the `Bool` with the relationship validity on success, or an error on failure.
    public func validateRelationship(
        for user: User,
        type: FollowRelationType,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let currentUserId = currentUser?.identifier
        else {
            completion(.failure(DatabaseError.cachedUserUidNil))
            return
        }
        
        // Form the path for the requested relation type.
        let path = L10n.Fir.userWithId(currentUserId) + "/" + type.rawValue
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            // Fetch the users belonging to that relation.
            guard let validUserIds = snapshot.value as? [String] else {
                completion(.failure(DatabaseError.fetchedValueNil(line: "\(#line)")))
                return
            }
            
            let isValidRelationship = validUserIds.contains(currentUserId)
            completion(.success(isValidRelationship))
        }
    }
}

/// A "D.R.Y." readability refactoring.
/// - parameters:
///   - completion: The completion block to which to pass along the results.
fileprivate func dbSetValueCompletion(withItsOwn completion: @escaping DatabaseRefResultCompletion) -> ((Error?, DatabaseReference) -> Void) {
    return { error, dbRef in
        if let error = error {
            print(error.localizedDescription)
            completion(.failure(error))
        } else {
            completion(.success(dbRef))
        }
    }
}
