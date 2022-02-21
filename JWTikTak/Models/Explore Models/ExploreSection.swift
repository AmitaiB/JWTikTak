//
//  ExploreSection.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import Foundation

struct ExploreSection {
    let type: ExploreSectionType
    let cells: [ExploreCell]
}

enum ExploreSectionType: CustomStringConvertible, CaseIterable {
    case banners
    case trending
    case users
    case trendingHashtags
    case recommended
    case popular
    case new
    
    
    var description: String { title }
    var title: String {
        switch self {
            case .banners:
                return "Featured"
            case .trending:
                return "Trending Videos"
            case .users:
                return "Fresh Creators"
            case .trendingHashtags:
                return "Hashtags"
            case .recommended:
                return "Recommended"
            case .popular:
                return "Popular"
            case .new:
                return "Recent Posts"
        }
    }
}
