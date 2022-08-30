//
//  ProfileHeaderViewModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/19/22.
//

import Foundation

/// Contains an image, follow relationship counts, and profile style.
struct ProfileHeaderViewModel: ViewModel {
    let avatarImageURL: URL?
    let followerCount: Int?
    let followingCount: Int?
    let profileStyle: Style
    
    /// Besides not/following, accounts for the case of the `currentUser` viewing their own profile.
    enum Style {
        case isFollowing
        case isNotFollowing
        case isLoggedInUser
    }
}
