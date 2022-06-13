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
    /// The post's video filename, with `.mov` extension.
    var filename: String
    /// The post's video filename, but with the `.png` extension.
    /// Generated locally when the video is first posted.
    var thumbnail: String { Self.getThumbnail(fromFilename: filename) }
    var caption: String
    // TODO: Likes should be tracked by Users, not by the Posts.
    var isLikedByCurrentUser: Bool
    
    static func getThumbnail(fromFilename filename: String) -> String {
        filename.dropLast(3) + "png"
    }
    
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
    var thumbnailPath: String {
        L10n.Fir.postThumbnailPathWithUidAndName(userUid, thumbnail)
    }
    // For debugging
    static func mockModels() -> [PostModel] {
        Array(0...100).compactMap({ index in
//            PostModel(identifier: UUID().uuidString)
            PostModel(identifier: UUID().uuidString,
                      userUid: "Mock User number #\(index)",
                      filename: "aFilename",
                      caption: "aCaption",
                      isLikedByCurrentUser: false)
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
