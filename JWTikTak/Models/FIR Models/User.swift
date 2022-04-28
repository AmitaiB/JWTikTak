//
//  User.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import Foundation

struct User: Codable {
    let username: String
    let profilePictureURL: URL?
    let identifier: String
    
    // test properties
    var email: String? = nil
    var posts: [String]?
    
    
    static var mock = User(
        username: "Jonny Appleseed",
        profilePictureURL: nil,
        identifier: UUID().uuidString,
        email: "jonny@appleseed.com"
    )
}
