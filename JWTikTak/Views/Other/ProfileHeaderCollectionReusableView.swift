//
//  ProfileHeaderCollectionReusableView.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/16/22.
//

import UIKit
import Reusable

class ProfileHeaderCollectionReusableView: UICollectionReusableView, Reusable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds   = true
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
