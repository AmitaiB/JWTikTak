//
//  Explore.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

/// Contains an image, title, and selection handler.
struct ExploreBannerViewModel: ViewModel {
    let image: UIImage?
    let title: String
    let handler: (() -> Void)?
}
