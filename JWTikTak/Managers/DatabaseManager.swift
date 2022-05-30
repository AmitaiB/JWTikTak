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

typealias UserDictionary = [String: User]
typealias DatabaseRefResultCompletion = (Result<DatabaseReference, Error>) -> Void

/// The Firebase db manager (for 'spreadsheet' data, such as users etc.).
final class DatabaseManager {
    // Singleton
    public static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private(set) var currentUser: User? = {
        guard let currentUser = Auth.auth().currentUser
        else { return nil }
        return User(withFIRUser: currentUser)
    }()
    
    public func updateCachedUser(with user: User?) {
        currentUser = user
    }
        
    // TODO: Remove this function.
//    public func updateCachedUserWith(username: String?) {
//        guard let username = username else { return }
//
//        let currentUserChildNodePath = L10n.Fir.users + "/" + username
//        database.child(currentUserChildNodePath).observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value else {
//                print(DatabaseError.fetchedValueNil(line: "line: \(#line)"))
//                return
//            }
//
//            self.currentUser = try? FirebaseDecoder().decode(User.self, from: value)
//        }
//    }
    
    enum DatabaseError: Error {
        case fetchedValueNil(line: String)
        case cachedUsernameNil
        case cachedUserUidNil
    }
    
    // Public
    /// Adds the new user to the realtime database (different from FIR's authentication database).
    /// - returns: A `Result` with a FIR Db reference containing a snapshot.
    public func insert(newUser user: UserModel,
                       completion: @escaping DatabaseRefResultCompletion
    ) {
        let newUserData = try! FirebaseEncoder().encode(user)
        let newChildNodePath = L10n.Fir.users + "/" + user.identifier
        
        database.child(newChildNodePath).setValue(
            newUserData,
            withCompletionBlock: dbSetValueCompletion(withItsOwn: completion))
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
        let postsDbRef  = database.child(L10n.Fir.posts)
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
    
    public func getAllUsers(completion: ([String]) -> Void) {
        
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
