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
