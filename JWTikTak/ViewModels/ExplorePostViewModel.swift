//
//  Explore.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

/// Contains an image, caption, and selection handler.
struct ExplorePostViewModel: ViewModel {
    let thumbnailImage: UIImage?
    let caption: String
    let handler: (() -> Void)?
}
