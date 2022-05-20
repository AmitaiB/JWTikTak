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
    let isFollowing: Bool?
    var isLoggedInUserProfile: Bool { isFollowing.isNone }
}
