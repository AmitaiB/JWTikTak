//
//  ExploreCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

/// Helps construct the `ExploreSection` view models.
enum ExploreCell {
    case banner(viewModel: ExploreBannerViewModel)
    case post(viewModel: ExplorePostViewModel)
    case hashtag(viewModel: ExploreHashtagViewModel)
    case user(viewModel: ExploreUserViewModel)
}
