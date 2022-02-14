//
//  PostModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/13/22.
//

import Foundation

struct PostModel: Equatable {
    /// A unique identifier
    let identifier: String
    
    // For debugging
    static func mockModels() -> [PostModel] {
        Array(0...100).compactMap({_ in
            PostModel(identifier: UUID().uuidString)
        })
    }
    
    static func ==(lhs: PostModel, rhs: PostModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

