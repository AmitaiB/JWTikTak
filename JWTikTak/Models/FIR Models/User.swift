//
//  User.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import Foundation

/// To help distinguish `JWTikTak.User` from `FIRUser`
typealias UserModel = User

// User UID is the primary key (see https://bit.ly/FirebaseDocs_StructureYourDb ).
struct User: Codable {
    // MARK: 'FIRAuth' properties
    /// Should be equal to its corresponding FIRUser's `uid`
    let identifier: String
    var email: String?        = nil
    var displayName: String?  = nil
    
    // MARK: 'Realtime Db' properties
    var profilePictureURL: URL? = nil
    var ownedPosts: [String]?
    //    var likedPosts: [String]?
    
    /// - warning: For UI purposes only. The email, in particular is an illegal path in FIR.
    /// - returns: Returns the `displayName`, else the `username`, else the `email`, else part of the User UID.
    var displayString: String { displayName ?? username ?? email ?? "\(identifier.prefix(5))..." }
    
    // TODO: phasee out the 'username'?
    var username: String? = nil
    
    static var empty = User(
        identifier: "867-5309",
        email: "please@sign.in"
    )
    
    
    // MARK: Inits
    
    init(withFIRUser fbUser: FIRUser) {
        identifier  = fbUser.uid
        email       = fbUser.email
        displayName = fbUser.displayName
    }
    
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

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
