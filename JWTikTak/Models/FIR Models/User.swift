//
//  User.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import Foundation

/// To help distinguish `JWTikTak.User` from `FIRUser`
typealias UserModel = User

extension UserModel: ViewModel {}

/// A struct modeling the defining properties of a user on the app/platform.
///
/// Includes identifying information, login credentials, and references to owned posts, pictures, and
/// other related users.
/// - note: `FIRUser` UID is the primary key, `identifier` (see [Firebase docs](https://bit.ly/FirebaseDocs_StructureYourDb)).
struct User: Codable {
    // MARK: 'FIRAuth' properties
    /// Is set to its corresponding FIRUser's `uid` on creation. Required.
    let identifier: String
    /// The user's email address. Optional.
    var email: String?        = nil
    /// The user's chosen readable name, for UI purposes only. Optional.
    var displayName: String?  = nil
    
    // MARK: 'Realtime Db' properties
    /// The URL to the user's profile picture on FIR.
    var profilePictureURL: URL? = nil
    /// A collection of UIDs for the posts this user has created.
    var ownedPosts: [String]?
    // TODO: var likedPosts: [String]?
    
    /// An array of User UIDs.
    var followers: [String]?
    /// An array of User UIDs.
    var following: [String]?
    
    /// A string intended for displaying in the UI, drawn from the user's optional properties.
    /// - warning: For UI purposes only. The email, in particular is an illegal path in FIR.
    /// - returns: Returns the `displayName`, else the `username`, else the `email`, else part of the User UID.
    var displayString: String { displayName ?? username ?? email ?? "\(identifier.prefix(5))..." }
    
    // TODO: Remove 'username' — not used anywhere.
    var username: String? = nil
    
    static var empty = User(
        identifier: "867-5309",
        email: "please@sign.in"
    )
    
    
    // MARK: Inits
    
    init(
        identifier: String,
        email: String? = nil,
        displayName: String? = nil,
        profilePictureURL: URL? = nil,
        ownedPosts: [String]? = nil,
        username: String? = nil
    ) {
        self.identifier        = identifier
        self.email             = email
        self.displayName       = displayName
        self.profilePictureURL = profilePictureURL
        self.ownedPosts        = ownedPosts
        self.username          = username
    }
}


// MARK: Equatable

// User is equatable by way of its unique primary key only.
extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

/// `String`-based `enum` cases: `followers` or `following`. Used in many places throughout the app
/// to define relationships between users.
enum FollowRelationType: String {
    case followers
    case following
}
