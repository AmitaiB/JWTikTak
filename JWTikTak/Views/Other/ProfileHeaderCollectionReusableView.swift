//
//  ProfileHeaderCollectionReusableView.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/16/22.
//

import UIKit
import Reusable

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    
}


class ProfileHeaderCollectionReusableView: UICollectionReusableView, Reusable {
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    // TODO: Refactor all these uiviews, images, and buttons into Theme(s) using their Appearance() proxies!
    // Subviews
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private var primaryButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    

    
    // MARK: Initialization
    
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
