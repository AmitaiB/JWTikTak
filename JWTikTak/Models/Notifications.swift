//
//  Notifications.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/9/22.
//

import Foundation

enum NotificationType: Equatable {
    case postLike(postId: String)
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
    
    static func mockData() -> [Notification] {
        let postLikes = Array(0...5).compactMap {
            Notification(text: "I like this!: \($0)",
                         type: .postLike(postId: "best post eva"),
                         date: Date())
        }
        
        let postComments = Array(0...5).compactMap {
            Notification(text: "Comment: \($0)",
                         type: .postComment(postId: "best comment eva"),
                         date: Date())
        }
        
        let userFollows = Array(0...5).compactMap {
            Notification(text: "Follow me: \($0)",
                         type: .userFollow(username: "Donkey Kong"),
                         date: Date())
        }
        
        return (postLikes + postComments + userFollows).shuffled()
    }
}
