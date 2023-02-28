//
//  MockObjects.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/28/23.
//

import Foundation

extension ExploreViewController {
    // TODO: MOCK Cells
    func configureMockModels() {
        let mockResponse = ExploreDataManager.shared
        
        // Banners
        sections += [ExploreSection(
            type:  .banners,
            cells: mockResponse.getExploreBanners()
                .map { ExploreCell.banner(viewModel: $0) }
        )]
        
        // Trending Posts
        sections += [ExploreSection(
            type:  .trending,
            cells: mockResponse.getExploreTrending()
                .map { ExploreCell.post(viewModel: $0) }
        )]
        
        // Users
        sections += [ExploreSection(
            type:  .users,
            cells: mockResponse.getExploreCreators()
                .map { ExploreCell.user(viewModel: $0) }
        )]
        
        // Hashtags
        sections += [ExploreSection(
            type:  .hashtags,
            cells: mockResponse.getExploreHashtags()
                .map { ExploreCell.hashtag(viewModel: $0) }
        )]
        
        // Recommended
        sections += [ExploreSection(
            type:  .recommended,
            cells: mockResponse.getExploreRecommended()
                .map { ExploreCell.post(viewModel: $0) }
        )]
        
        // Popular
        sections += [ExploreSection(
            type:  .popular,
            cells: mockResponse.getExplorePopular()
                .map { ExploreCell.post(viewModel: $0) }
        )]
        
        // Recent Posts
        sections += [ExploreSection(
            type:  .recent,
            cells: mockResponse.getExploreRecent()
                .map { ExploreCell.post(viewModel: $0) }
        )]
    }

}

extension Notification {
    static func mockData() -> [Notification] {
        let postLikes = Array(0...5).compactMap {
            Notification(text: "I like this!: \($0)",
                         type: .postLike(postId: "best post eva"),
                         date: Date())
        }
        
        let postComments = Array(0...5).compactMap {
            Notification(text: "Comment: \($0)",
                         type: .postComment(postId: "best comment eva"),
                         date: Date())
        }
        
        let userFollows = Array(0...5).compactMap {
            Notification(text: "Follow me: \($0)",
                         type: .userFollow(username: "Donkey Kong"),
                         date: Date())
        }
        
        return (postLikes + postComments + userFollows).shuffled()
    }
}

extension PostModel {
    static func mockModels() -> [PostModel] {
        Array(0...100).compactMap({ index in
            let userUIDs = [L10n.UserUID.johnDoe, L10n.UserUID.ablickstein, L10n.UserUID.amitai]
            return PostModel(identifier: UUID().uuidString,
                             userUid: userUIDs.randomElement()!,
                             filename: StorageManager.generateVideoIdentifier(),
                             caption: "John's best example of a doe",
                             isLikedByCurrentUser: false)
        })
    }

}

extension PostComment {
    static func mockComments() -> [PostComment] {
        let user = User(identifier: UUID().uuidString,
                        profilePictureURL: nil,
                        username: "oswaldfriend")
        
        return [
            "Look at my amazing post!",
            "Hey, its another post — ya boy!",
            "I'm learning so much!",
        ].map {PostComment(text: $0, user: user, date: Date())}
    }
}
