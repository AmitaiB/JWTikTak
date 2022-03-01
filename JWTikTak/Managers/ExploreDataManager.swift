//
//  ExploreManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/22/22.
//

import UIKit
import SDWebImage

final class ExploreDataManager {
    static let shared = ExploreDataManager()
    private init() {}
    
    public func getExploreBanners() -> [ExploreBannerViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let bannerModels = response.banners.compactMap {
                    ExploreBannerViewModel(
                        image: UIImage(named: $0.image), //UIImage(contentsOf: URL(string: $0.image)),
                        title: $0.title,
                        handler: nil)
                }
                return bannerModels
            
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// "Creators" are `User` model objects.
    public func getExploreCreators() -> [ExploreUserViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let userModels = response.creators.compactMap {
                    ExploreUserViewModel(
                        profileImage: UIImage(named: $0.image),
                        username: $0.username,
                        followerCount: $0.followersCount,
                        handler: nil)
                }
                return userModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    public func getExploreHashtags() -> [ExploreHashtagViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let hashtagModels = response.hashtags.compactMap {
                    ExploreHashtagViewModel(
                        icon: UIImage(named: $0.image),
                        text: "#" + $0.tag,
                        count: $0.count,
                        handler: nil)
                }
                return hashtagModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    public func getExploreTrending() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let popularPostModels = response.trendingPosts.compactMap {
                    ExplorePostViewModel(
                        thumbnailImage: UIImage(named: $0.image),
                        caption: $0.caption,
                        handler: nil)
                }
                return popularPostModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    public func getExplorePopular() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let popularPostModels = response.popular.compactMap {
                    ExplorePostViewModel(
                        thumbnailImage: UIImage(named: $0.image),
                        caption: $0.caption,
                        handler: nil)
                }
                return popularPostModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// "recent" is modeled by `.new` models/cells.
    public func getExploreRecent() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let newPostModels = response.recentPosts.compactMap {
                    ExplorePostViewModel(
                        thumbnailImage: UIImage(named: $0.image),
                        caption: $0.caption,
                        handler: nil)
                }
                return newPostModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    public func getExploreRecommended() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let recommendedPostModels = response.recommended.compactMap {
                    ExplorePostViewModel(
                        thumbnailImage: UIImage(named: $0.image),
                        caption: $0.caption,
                        handler: nil)
                }
                return recommendedPostModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    enum ExploreError: Error {
        case path(String)
        case decoding(String)
    }
    
    private func parseExploreData() -> Result<ExploreResponse, Error> {
        guard let path = Bundle.main.path(forResource: "explore", ofType: "json")
        else { return .failure(ExploreError.path("line: \(#line)"))}
        
        let url  = URL(fileURLWithPath: path)
        
        do {
            let jsonData = try Data(contentsOf: url)
            let exploreResponse = try JSONDecoder().decode(
                ExploreResponse.self,
                from: jsonData)
            return .success(exploreResponse)
            
        } catch {
            print(error.localizedDescription, " line: \(#line)")
            return .failure(ExploreError.decoding("line: \(#line)"))
        }
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let exploreResponse = try? newJSONDecoder().decode(ExploreResponse.self, from: jsonData)

// MARK: - ExploreResponse
struct ExploreResponse: Codable {
    let banners: [Banner]
    let hashtags: [Hashtag]
    let creators: [Creator]
    let trendingPosts, recentPosts, popular, recommended: [Post]
    
    
    // MARK: - Banner
    struct Banner: Codable {
        let id, image, title, action: String
    }
    
    // MARK: - Post
    struct Post: Codable {
        let id, image, caption: String
    }

    // MARK: - Hashtag
    struct Hashtag: Codable {
        let image, tag: String
        let count: Int
    }
    
    // MARK: - Creator
    struct Creator: Codable {
        let id, image, username: String
        let followersCount: Int
        
        enum CodingKeys: String, CodingKey {
            case id, image, username
            case followersCount = "followers_count"
        }
    }
}
