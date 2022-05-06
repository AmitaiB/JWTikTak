//
//  ExploreManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/22/22.
//

import UIKit
import SDWebImage

protocol ExploreDataManagerDelegate: AnyObject {
    func pushViewController(_ viewController: UIViewController)
    func didTapHashtag(_ hashtag: String)
}

final class ExploreDataManager {
    static let shared = ExploreDataManager()
    private init() {}
    
    weak var delegate: ExploreDataManagerDelegate?
    
    enum BannerAction: String {
        case post, hashtag, user
    }
    
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
    
    /// "Creators" are `User` model objects.
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
                            let mockVC = ProfileViewController(user: User(
                                username: "Joe",
                                profilePictureURL: nil,
                                identifier: userId))
                            self?.delegate?.pushViewController(mockVC)
                        }
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
    
    public func getExploreTrending() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.trendingPosts, with: delegate)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    public func getExplorePopular() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.popular, with: delegate)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    /// "recent" is modeled by `.new` models/cells.
    public func getExploreRecent() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.recentPosts, with: delegate)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
    
    public func getExploreRecommended() -> [ExplorePostViewModel] {
        switch parseExploreData() {
            case .success(let response):
                return getPostViewModels(from: response.recommended, with: delegate)
            case .failure(let error):
                print(error.localizedDescription, " line: \(#line)")
                return []
        }
    }
        
    private func getPostViewModels(from posts: [ExploreResponse.Post], with delegate: ExploreDataManagerDelegate?) -> [ExplorePostViewModel] {
        posts.compactMap { model in
            ExplorePostViewModel(
                thumbnailImage: UIImage(named: model.image),
                caption: model.caption) {
                    // use id to fetch post from firebase
                    let mockPostModel = PostModel(identifier: model.id)
                    let mockVC = PostViewController(model: mockPostModel)
                    delegate?.pushViewController(mockVC)
                }
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
