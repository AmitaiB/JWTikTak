//
//  Explore.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

/// Contains a profile image, username, follower count, and selection handler.
struct ExploreUserViewModel: ViewModel {
    let profileImage: UIImage?
    let username: String
    let followerCount: Int
    let handler: (() -> Void)?
}
