//
//  DatabaseManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseDatabase
import CodableFirebase

typealias UserDictionary = [String: User]
typealias DatabaseRefResultCompletion = (Result<DatabaseReference, Error>) -> Void

/// The Firebase db manager (for 'spreadsheet' data, such as users etc.).
final class DatabaseManager {
    // Singleton
    public static let shared = DatabaseManager()
    private init() {}
    
    private let database = Database.database().reference()
    
    enum DatabaseError: Error {
        case fetchedValueNil(line: String)
        case cachedUsernameNil
    }
    
    // Public
    
    public func insertUser(
        withEmail email: String,
        username: String,
        completion: @escaping DatabaseRefResultCompletion
    ) {
        let newUser = User(username: username,
                           profilePictureURL: nil,
                           identifier: UUID().uuidString,
                           email: email)
        let newUserData = try! FirebaseEncoder().encode(newUser)
        let newChildNodePath = L10n.Fir.users + "/" + username
        
        database.child(newChildNodePath).setValue(
            newUserData,
            withCompletionBlock: dbSetValueCompletion(withItsOwn: completion))
    }
    
    public func getUsername(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        database.child(L10n.Fir.users)
            .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value else {
                    let error = DatabaseError.fetchedValueNil(line: "line: \(#line)")
                    completion(.failure(error))
                    return
                }
                
                do {
                    let usersDict = try FirebaseDecoder().decode(UserDictionary.self,
                                                                 from: value)
                    usersDict
                        .values
                        .first(where: {email == $0.email})
                        .ifThen { completion(.success($0.username)) }
                    
                } catch { print(error.localizedDescription) }
            }
    }
    
    
    /// Adds a post to the Firebase RealTime Database
    /// - Parameters:
    ///   - filename: The video filename, with extension, e.g., `myVideo.mov`.
    ///   - completion: Handles the server response.
    public func insertPost(filename: String, completion: @escaping DatabaseRefResultCompletion) {
        guard let username = AuthManager.shared.currentUsername else {
            completion(.failure(DatabaseError.cachedUsernameNil))
            return
        }
        
        let userDbRef = database.child(L10n.Fir.users).child(username)
        
        userDbRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                let error = DatabaseError.fetchedValueNil(line: "line: \(#line)")
                completion(.failure(error))
                return
            }
            
            do {
                // decode -> update local obj -> encode -> update remote db
                var user = try FirebaseDecoder().decode(User.self, from: value)
                
                if var posts = user.posts {
                    posts.append(filename)
                } else {
                    user.posts = [filename]
                }
                
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
}

// D.R.Y.
/// - parameters:
///   - passthrough: The completion block to which to pass along the results.
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
