//
//  ProfileHeaderCollectionReusableView.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/16/22.
//

import UIKit
import Reusable
import SnapKit

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapPrimaryButtonWith viewModel: ViewModel)
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowersButtonWith viewModel: ViewModel)
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowingButtonWith viewModel: ViewModel)
}


class ProfileHeaderCollectionReusableView: UICollectionReusableView, Reusable {
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    var viewModel: ProfileHeaderViewModel?
    
    // TODO: Fix Corner radius of avatar image view
    // Subviews
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds       = true
        imageView.contentMode         = .scaleAspectFill
        imageView.backgroundColor     = .secondarySystemBackground
        return imageView
    }()
    
    private lazy var primaryButton: UIButton = {
        let button = getButton(withTitle: "FOLLOW",
                               fontStyle: .largeTitle,
                               backgroundColor: .systemPink)
        button.addAction { [self] in
            guard let viewModel = viewModel
            else { return }

            delegate?.profileHeaderCollectionReusableView(self, didTapPrimaryButtonWith: viewModel)
        }
        return button
    }()
    
    private lazy var followersButton: UIButton = {
        let button = getButton(withTitle: L10n.followers, displayCount: 0, numberOfLines: 2)
        button.addAction { [self] in
            guard let viewModel = viewModel
            else { return }

            delegate?.profileHeaderCollectionReusableView(self, didTapFollowersButtonWith: viewModel)
        }
        return button
    }()
    
    private lazy var followingButton: UIButton = {
        let button = getButton(withTitle: L10n.following, displayCount: 0, numberOfLines: 2)
        button.addAction { [self] in
            guard let viewModel = viewModel
            else { return }
            
            delegate?.profileHeaderCollectionReusableView(self, didTapFollowingButtonWith: viewModel)
        }
        return button
    }()
    
    private func getButton(withTitle title: String,
                           displayCount: Int? = nil,
                           numberOfLines: Int = 0,
                           fontStyle: UIFont.TextStyle = .title2,
                           backgroundColor: UIColor = .systemFill) -> UIButton
    {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = backgroundColor
        config.cornerStyle    = .dynamic
        config.title          = displayCount?.intStringValue
        config.titleAlignment = .center
        config.subtitle       = title
        config.contentInsets  = NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
        config.titlePadding   = 2
        
        let button = UIButton(configuration: config)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.font = .preferredFont(forTextStyle: fontStyle)
        return button
    }

    lazy var followStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [followingButton, followersButton])
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds   = true
        backgroundColor = .systemBackground
        addSubviews([avatarImageView, primaryButton, followStack])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // avatar Image View
        let avatarSize = 130
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(avatarSize)
        }
        avatarImageView.layer.cornerRadius = avatarImageView.height / 2
        
        followStack.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.left.right.equalTo(followStack)
            make.top.equalTo(followStack.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
    }
}

extension ProfileHeaderCollectionReusableView: ViewModelConfigurable {
    func configure(with viewModel: ViewModel) {
        avatarImageView.layer.cornerRadius = avatarImageView.height / 2
        guard let viewModel = viewModel as? ProfileHeaderViewModel
        else { return }
        
        followersButton.titleLabel?.text = viewModel.followerCount.intStringValue
        followingButton.titleLabel?.text = viewModel.followingCount.intStringValue
        
        if let avatarURL = viewModel.avatarImageURL {
            // download and assign
        } else {
            avatarImageView.image = Asset.test.image
        }
        
        if let isFollowing = viewModel.isFollowing {
            primaryButton.backgroundColor = isFollowing ? .secondarySystemBackground : .systemPink
            primaryButton.setTitle(isFollowing ? "Unfollow" : "Follow",
                                   for: .normal)
        } else {
            primaryButton.backgroundColor = .secondarySystemBackground
            primaryButton.setTitle("Edit Profile", for: .normal)
        }
    }
}
