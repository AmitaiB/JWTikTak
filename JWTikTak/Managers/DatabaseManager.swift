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
typealias DatabaseRefResultCompletion = (Result<DatabaseReference, Error>) -> Void

/// The Firebase db manager (for 'spreadsheet' data, such as users etc.).
final class DatabaseManager: NSObject {
    // Singleton
    public static let shared = DatabaseManager()
    private override init() {
        super.init()
        NotificationCenter.default
            .add(observer: self, name: .FIRAuthStateDidChange) { [weak self] in
                self?.handleAuthStateUpdate(possibleFIRUser: $0.object)
            }
        
        refreshCurrentUserIfNeeded()
    }
        
    private let database = Database.database().reference()
    
    private(set) var currentUser: User? {
        didSet {
            NotificationCenter.default
                .post(name: .DatabaseManagerDidUpdateCurrentUser, object: currentUser)
        }
    }
    
    // Use the FIRAuth's User UID to get the Db's User object.
    private func handleAuthStateUpdate(possibleFIRUser object: Any?) {
        // startup and sign in
        if let firUser = object as? FIRUser {
            getUser(withId: firUser.uid) { [weak self] result in
                switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let user):
                        self?.updateCachedUser(with: user)
                }
            }
        }
        else {
            // signed out
            updateCachedUser(with: .none)
        }
    }
    
    public func updateCachedUser(with user: User?) {
        currentUser = user
    }
    
    /// Can update any `User` value except for the primary key, the `identifier` property.
    /// - Parameters:
    ///   - shouldSync: After updating the local value, will update those values on the server.
    public func updateCachedUserValues(newEmail: String?         = nil,
                                       newDisplayName: String?   = nil,
                                       newProfilePicURL: URL?    = nil,
                                       newOwnedPosts: [String]?  = nil,
                                       newUsername: String?      = nil,
                                       shouldSync: Bool          = false
    ) {
        newEmail        .ifSome { currentUser?.email             = $0 }
        newDisplayName  .ifSome { currentUser?.displayName       = $0 }
        newProfilePicURL.ifSome { currentUser?.profilePictureURL = $0 }
        newOwnedPosts   .ifSome { currentUser?.ownedPosts        = $0 }
        newUsername     .ifSome { currentUser?.username          = $0 }
        
        if shouldSync {
            syncCurrentUser(withStrategy: .ours)
        }
    }
    
    enum SyncStrategy {
        /// Overwrites the server with the local version.
        case ours
        /// Overwrites the local version with the server's version.
        case theirs
    }
    
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
    /// Adds the new user to the realtime database (different from FIR's authentication database).
    /// - returns: A `Result` with a FIR Db reference containing a snapshot.
    public func insert(user: UserModel,
                       completion: @escaping DatabaseRefResultCompletion
    ) {
        let userData = try! FirebaseEncoder().encode(user)
        let path = L10n.Fir.userWithId(user.identifier)
        
        database.child(path).setValue(
            userData,
            withCompletionBlock: dbSetValueCompletion(withItsOwn: completion))
    }
    

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
    
    /// Adds a post to the Firebase RealTime Database
    /// - Parameters:
    ///   - filename: The video filename, with extension, e.g., `myVideo.mov`.
    ///   - caption: User input caption for video.
    ///   - completion: Handles the server response.
    public func insert(newPost: PostModel, completion: @escaping DatabaseRefResultCompletion) {
        // TODO: See if this can be condensed to one call, using `updateChildValues`: https://firebase.google.com/docs/database/ios/read-and-write#update_specific_fields
        updateRootArrayOfPosts(with: newPost, completion: completion)
        updateUserListOfPostsIDs(with: newPost, completion: completion)
    }
    
    /// RealtimeDb has a flat hierarchy, so Posts exist separately, while Users just have an array of references. Both need to be updated.
    private func updateRootArrayOfPosts(with newPost: PostModel, completion: @escaping DatabaseRefResultCompletion) {
        let newPostData = try? FirebaseEncoder().encode(newPost)
        let postsDbRef  = database.child(L10n.Fir.postWithId(newPost.identifier))
        postsDbRef.setValue(newPostData,
                            withCompletionBlock: dbSetValueCompletion(withItsOwn: completion))
    }
    
    /// RealtimeDb has a flat hierarchy, so Posts exist separately, while Users just have an array of references. Both need to be updated.
    private func updateUserListOfPostsIDs(with newPost: PostModel, completion: @escaping DatabaseRefResultCompletion) {
        guard let uid = currentUser?.identifier else {
            completion(.failure(DatabaseError.cachedUserUidNil))
            return
        }
        
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
                                   withCompletionBlock: dbSetValueCompletion(withItsOwn: completion))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Self-descriptive.
    ///
    /// There is no guarantee that this singleton will exist at the time that the AuthManager singleton
    /// posts its notification about the state of the current User. If they are out of sync, this method
    /// will synchronize this DatabaseManager.
    private func refreshCurrentUserIfNeeded() {
        let currentUserNeedsRefresh = Auth.auth().currentUser.isSome && currentUser.isNone
        
        if currentUserNeedsRefresh {
            handleAuthStateUpdate(possibleFIRUser: Auth.auth().currentUser)
        }
    }
        
    
    
    // MARK: - Notifications

    public func getNotifications(completion: @escaping (Result<[Notification], Error>) -> Void) {
        completion(.success(Notification.mockData()))
    }
    
    // TODO: replace the (Bool) -> Voids with Result<User, Error> or whatnot.
    // TODO: TODO: Replace completion blocks with await/async!
    public func markNotificationAsHidden(withId id: String, completion: @escaping (Bool) -> Void) {
        // debug trivial mock result
        completion(true)
    }
    
    public func follow(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        // debug trivial mock result
        completion(.success(User(identifier: "fake user ID", username: username)))
    }

    
    // MARK: - Posts
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
