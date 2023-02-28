//
//  Notifications.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/9/22.
//

import Foundation

/// The types of events to which user's may subscribe. Includes post likes and comments, and follows.
enum NotificationType: Equatable {
    case postLike(postId: String)
    // TODO: When username is removed, change to user.identifier
    case userFollow(username: String)
    case postComment(postId: String)
    
    var id: String {
        switch self {
            case .postLike:     return L10n.postLike
            case .userFollow:   return L10n.userFollow
            case .postComment:  return L10n.postComment
        }
    }
}

// TODO: The postId/postId should equal the `id` property.
/// A Notification has a `NotificationType` enum, from which the primary key can be extracted.
class Notification {
    var id = UUID().uuidString
    var isHidden = false
    let text: String
    let type: NotificationType
    let date: Date

    init(text: String, type: NotificationType, date: Date) {
        self.text = text
        self.type = type
        self.date = date
    }
}
