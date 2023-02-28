//
//  PostCommentModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import Foundation

/// Models another user's comment to a post, including the time.
struct PostComment {
    let text: String
    let user: User
    let date: Date
}
