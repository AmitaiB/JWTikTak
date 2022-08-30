//
//  ExploreSection.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import Foundation

/// A view model for the `ExploreViewController`'s table view.
struct ExploreSection {
    let type: ExploreSectionType
    let cells: [ExploreCell]
}

/// Each type is presented in its own section in the `ExploreViewController`.
enum ExploreSectionType: CustomStringConvertible, CaseIterable {
    case banners
    case trending
    case users
    case hashtags
    case recommended
    case popular
    case recent
    
    
    var description: String { title }
    var title: String {
        switch self {
            case .banners:
                return "Featured"
            case .trending:
                return "What's Trending"
            case .users:
                return "Fresh Creators"
            case .hashtags:
                return "Hashtags"
            case .recommended:
                return "Recommended"
            case .popular:
                return "Popular"
            case .recent:
                return "Recent"
        }
    }
}
