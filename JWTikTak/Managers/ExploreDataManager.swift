//
//  ExploreManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/22/22.
//

import UIKit
import SDWebImage

/// Delegate interface to notify of manager events.
protocol ExploreDataManagerDelegate: AnyObject {
    func pushViewController(_ viewController: UIViewController)
    func didTapHashtag(_ hashtag: String)
}

/// Manager that handles the explore scene content.
final class ExploreDataManager {
    /// Shared singleton instance.
    static let shared = ExploreDataManager()
    private init() {}
    
    weak var delegate: ExploreDataManagerDelegate?
    
    /// An action type underlying an interaction enabled control.
    enum BannerAction: String {
        /// Post type.
        case post
        /// Hashtag search type.
        case hashtag
        /// Creator type.
        case user
    }
    
    /// Gets explore data for popular posts.
    /// - Returns: A collection of explore banner models.
    public func getExploreBanners() -> [ExploreBannerViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let bannerModels = response.banners.compactMap { model in
                    ExploreBannerViewModel(
                        image: UIImage(named: model.image), //UIImage(contentsOf: URL(string: $0.image)),
                        title: model.title) { [weak self] in
                            guard let action = BannerAction(rawValue: model.action) else { return }
                            let mockVC = UIViewController()
                            mockVC.view.backgroundColor = .systemRed
                            mockVC.title = action.rawValue.uppercased()
                            self?.delegate?.pushViewController(mockVC)
                            
                            switch action {
                                case .user:
                                    // TODO: present user profile
                                    break
                                case .post:
                                    // TODO: present post
                                    break
                                case .hashtag:
                                    // TODO: search for hashtag
                                    break
                            }
                        }
                }
                return bannerModels
            
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// Gets explore data for popular posts.
    /// - Returns: A collection of explore creator models, that is, `User` model objects.
    public func getExploreCreators() -> [ExploreUserViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let userModels = response.creators.compactMap { model in
                    ExploreUserViewModel(
                        profileImage: UIImage(named: model.image),
                        username: model.username,
                        followerCount: model.followersCount) { [weak self] in
                            let userId = model.id
                            // TODO: Fetch user object from firebase
                            let mockVC = ProfileViewController(userId: userId)
                            self?.delegate?.pushViewController(mockVC)
                        }
                }
                return userModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// Gets explore data for popular posts.
    /// - Returns: A collection of explore hashtag search models.
    /// - Warning: Not fully implemented!
    public func getExploreHashtags() -> [ExploreHashtagViewModel] {
        switch parseExploreData() {
            case .success(let response):
                let hashtagModels = response.hashtags.compactMap { model in
                    ExploreHashtagViewModel(
                        icon: UIImage(named: model.image),
                        text: "#" + model.tag,
                        count: model.count) { [weak self] in                            self?.delegate?.didTapHashtag(model.tag)
                        }
                }
                return hashtagModels
                
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// Gets explore data for trending posts.
    /// - Returns: A collection of explore post models.
    public func getExploreTrending() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.trendingPosts)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// Gets explore data for popular posts.
    /// - Returns: A collection of explore banner models.
    public func getExplorePopular() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.popular)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    
    /// Gets explore data for recent posts.
    /// - Returns: A collection of explore post models.
    /// - Note: "recent" is modeled by `.new`-type models/cells.
    public func getExploreRecent() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.recentPosts)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// Gets explore data for recommended posts.
    /// - Returns: A collection of explore post models.
    public func getExploreRecommended() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.recommended)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// Handler for successful parsing of explore JSON data.
    /// - Parameters:
    ///   - posts: The native object mapped from the JSON response.
    ///   - delegate:
    /// - Returns: A collection of explore post models.
    private func getPostViewModels(from posts: [ExploreResponse.Post]) -> [ExplorePostViewModel] {
        posts.compactMap { [weak self] model in
            ExplorePostViewModel(
                thumbnailImage: UIImage(named: model.image),
                caption: model.caption) {
                    // use id to fetch post from firebase
                    let mockPostModel = PostModel(identifier: model.id)
                    let mockVC = PostViewController(model: mockPostModel)
                    self?.delegate?.pushViewController(mockVC)
                }
        }
    }
    
    /// Parses explore JSON data.
    /// - Returns: A `Result` wrapping a response model.
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

/// Models an Explore page's Banner, Post, Hashtag, and Creators' properties, to be mapped from JSON data.
struct ExploreResponse: Codable {
    let banners: [Banner]
    let hashtags: [Hashtag]
    let creators: [Creator]
    let trendingPosts, recentPosts, popular, recommended: [Post]
    
    
    // MARK: - Banner
    
    /// Models an Explore Banner's properties, to be mapped from JSON data.
    struct Banner: Codable {
        let id, image, title, action: String
    }
    
    // MARK: - Post
    
    /// Models an Explore Post's properties, to be mapped from JSON data.
    struct Post: Codable {
        let id, image, caption: String
    }

    // MARK: - Hashtag
    
    /// /// Models an Explore Hashtag's properties, to be mapped from JSON data.
    struct Hashtag: Codable {
        let image, tag: String
        let count: Int
    }
    
    // MARK: - Creator
    
    /// Models an Explore Banner's properties, to be mapped from JSON data.
    struct Creator: Codable {
        let id, image, username: String
        let followersCount: Int
        
        enum CodingKeys: String, CodingKey {
            case id, image, username
            case followersCount = "followers_count"
        }
    }
}
