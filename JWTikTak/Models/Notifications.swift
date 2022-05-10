//
//  Notifications.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/9/22.
//

import Foundation

enum NotificationType {
    case postLike(postName: String)
    case userFollow(username: String)
    case postComment(postName: String)
    
    var id: String {
        switch self {
            case .postLike: return "postLike"
            case .userFollow: return "userFollow"
            case .postComment: return "postComment"
        }
    }
}

struct Notification {
    let text: String
    let type: NotificationType
    let date: Date
    
    static func mockData() -> [Notification] {
        let postLikes = Array(0...5).compactMap {
            Notification(text: "I like this!: \($0)",
                         type: .postLike(postName: "best post eva"),
                         date: Date())
        }
        
        let postComments = Array(0...5).compactMap {
            Notification(text: "Comment: \($0)",
                         type: .postComment(postName: "best comment eva"),
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
