//
//  Explore.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

/// Contains an image, text, count of posts with this tag, and selection handler.
struct ExploreHashtagViewModel: ViewModel {
    let icon: UIImage?
    let text: String
    /// Number of posts associated with a given tag.
    let count: Int
    let handler: (() -> Void)?
}
