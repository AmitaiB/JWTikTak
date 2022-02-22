//
//  Explore.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

struct ExploreHashtagViewModel: ViewModel {
    let icon: UIImage?
    let text: String
    /// Number of posts associated with a given tag
    let count: Int
    let handler: (() -> Void)?
}
