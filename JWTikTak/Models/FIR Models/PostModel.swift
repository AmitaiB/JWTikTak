//
//  PostModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/13/22.
//

import Foundation

// TODO: username -> displayName; user -> uuid, maybe?
struct PostModel: Codable {
    /// A unique identifier.
    let identifier: String
    /// The FIR-generated User UID of the post's creator.
    var userUid: String
    /// Video filename.
    var filename: String
    var caption: String
    // TODO: Likes should be tracked by Users, not by the Posts.
    var isLikedByCurrentUser: Bool
    
    init(identifier: String = UUID().uuidString,
         userUid:  String = DatabaseManager.shared.currentUser?.identifier ?? User.empty.identifier,
         filename: String = "",
         caption:  String = "",
         isLikedByCurrentUser: Bool = false
    ) {
        self.identifier = identifier
        self.userUid = userUid
        self.filename = filename
        self.caption  = caption
        self.isLikedByCurrentUser = isLikedByCurrentUser
    }
    
    var videoPath: String {L10n.Fir.postVideoPathWithUidAndName(userUid, filename)}
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

extension PostModel: Comparable {
    static func < (lhs: PostModel, rhs: PostModel) -> Bool {
        lhs.identifier < rhs.identifier
    }
}

extension PostModel: ViewModel {}
