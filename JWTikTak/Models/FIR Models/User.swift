//
//  User.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import Foundation

struct User: Codable {
    let username: String
    var profilePictureURL: URL? = nil
    let identifier: String
    
    // test properties
    var email: String? = nil
    var ownedPosts: [String]?
//    var likedPosts: [String]?
    
    
    static var mock = User(
        username: "Jonny Appleseed",
        identifier: UUID().uuidString,
        email: "jonny@appleseed.com"
    )
}
