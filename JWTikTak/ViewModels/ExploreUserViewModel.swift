//
//  Explore.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

struct ExploreUserViewModel: ViewModel {
    let profilePicURL: URL?
    let username: String
    let followerCount: Int
    let handler: (() -> Void)?
}
