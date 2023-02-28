//
//  PostModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/13/22.
//

import Foundation

// TODO: username -> displayName; user -> uuid, maybe?

/// A struct modeling the defining properties of a user's post on the app/platform.
struct PostModel: Codable {
    /// A unique identifier.
    let identifier: String
    /// The FIR-generated User UID of the post's creator.
    var userUid: String
    /// The post's video filename, with `.mov` extension.
    var filename: String
    /// The post's video filename, but with the `.png` extension.
    /// Generated locally when the video is first posted.
    var thumbnail: String { Self.getThumbnailFilename(fromVideoFilename: filename) }
    /// The user-generated text displayed with the post.
    var caption: String
    // TODO: Likes should be tracked by Users, not by the Posts.
    var isLikedByCurrentUser: Bool
    
    /// Used to both generate and retrieve the thumbnail's filename as a function of its video's.
    /// - Parameter filename: The filename of the post's video, usually `.mov` or `.mp4`.
    /// - Returns: The filename with a `.png` extension. For example, `myPost{uniqueID}.mov` should
    /// have a thumbnail named `myPost{uniqueID}.png`.
    static func getThumbnailFilename(fromVideoFilename filename: String) -> String {
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
    
    /// The full path of the video in FIR, including filename.
    var videoPath: String {L10n.Fir.postVideoPathWithUidAndName(userUid, filename)}
    /// /// The full path of the thumbnail in FIR, including filename.
    var thumbnailPath: String {L10n.Fir.postThumbnailPathWithUidAndName(userUid, thumbnail)}    
}

// PostModel is equatable by way of its unique primary key only.
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
