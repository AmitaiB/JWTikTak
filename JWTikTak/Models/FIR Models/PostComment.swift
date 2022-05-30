//
//  PostCommentModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import Foundation

struct PostComment {
    let text: String
    let user: User
    let date: Date
    
    static func mockComments() -> [PostComment] {
        let user = User(identifier: UUID().uuidString,
                        profilePictureURL: nil,
                        username: "oswaldfriend")
        
        return [
            "Look at my amazing post!",
            "Hey, its another post — ya boy!",
            "I'm learning so much!",
        ].map {PostComment(text: $0, user: user, date: Date())}
    }
}
