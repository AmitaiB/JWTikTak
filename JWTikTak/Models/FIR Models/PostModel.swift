//
//  PostModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/13/22.
//

import Foundation

// TODO: username -> displayName; user -> uuid, maybe?
struct PostModel: Codable {
    init(identifier: String = UUID().uuidString,
         user: User = User.mock,
         username: String = DatabaseManager.shared.currentUser?.username ?? "",
         filename: String = "",
         caption: String = "",
         isLikedByCurrentUser: Bool = false
    ) {
        self.identifier = identifier
        // TODO: remove the `User` property from this model.
        self.user     = user
        self.username = username
        self.filename = filename
        self.caption  = caption
        self.isLikedByCurrentUser = isLikedByCurrentUser
    }
    // 'Backend' properties
    /// A unique identifier
    let identifier: String
    var user: User?
    var username: String
    /// Video filename
    var filename: String
    var caption: String
    // TODO: Likes should be tracked by Users, not by the Posts.
    var isLikedByCurrentUser: Bool
    
    // For debugging
    static func mockModels() -> [PostModel] {
        Array(0...100).compactMap({_ in
            PostModel(identifier: UUID().uuidString)
        })
    }
}

extension PostModel: Equatable {
    static func ==(lhs: PostModel, rhs: PostModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

