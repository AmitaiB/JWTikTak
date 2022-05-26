//
//  ProfileHeaderViewModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/19/22.
//

import Foundation

struct ProfileHeaderViewModel: ViewModel {
    let avatarImageURL: URL?
    let followerCount: Int
    let followingCount: Int
    let profileStyle: Style
    
    enum Style {
        case isFollowing
        case isNotFollowing
        case isLoggedInUser
    }
}
