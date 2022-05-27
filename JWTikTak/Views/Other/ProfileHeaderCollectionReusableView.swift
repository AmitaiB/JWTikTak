//
//  ProfileHeaderCollectionReusableView.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/16/22.
//

import UIKit
import Reusable
import SnapKit
import SDWebImage

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapPrimaryButtonWith viewModel: ViewModel)
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowersButtonWith viewModel: ViewModel)
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowingButtonWith viewModel: ViewModel)
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapAvatarImageWith viewModel: ViewModel)
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
    
    
    // MARK: - Subviews
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
        let button = getButton(withTitle: L10n.followers,
                               displayCount: 0,
                               numberOfLines: 2)
        button.addAction { [self] in
            guard let viewModel = viewModel
            else { return }

            delegate?.profileHeaderCollectionReusableView(self, didTapFollowersButtonWith: viewModel)
        }
        return button
    }()
    
    private lazy var followingButton: UIButton = {
        let button = getButton(withTitle: L10n.following,
                               displayCount: 0,
                               numberOfLines: 2)
        button.addAction { [self] in
            guard let viewModel = viewModel
            else { return }
            
            delegate?.profileHeaderCollectionReusableView(self, didTapFollowingButtonWith: viewModel)
        }
        return button
    }()
    
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImage))
        avatarImageView.addGestureRecognizer(tap)
        avatarImageView.isUserInteractionEnabled = true
    }
    
    @objc
    func didTapAvatarImage() {
        
        guard let viewModel = viewModel
        else { return }

        delegate?.profileHeaderCollectionReusableView(self, didTapAvatarImageWith: viewModel)
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
    
    // MARK: - Helpers
    private func getButton(withTitle title: String,
                           displayCount: Int? = nil,
                           numberOfLines: Int = 0,
                           fontStyle: UIFont.TextStyle = .title2,
                           backgroundColor: UIColor = .systemFill) -> UIButton
    {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = backgroundColor
        config.cornerStyle    = .fixed
        config.title          = title
        config.subtitle       = displayCount?.intStringValue
        config.titleAlignment = .center
        config.contentInsets  = [\.horizontal: 5, \.vertical: 2]
        config.titlePadding   = 2
        
        let button = UIButton(configuration: config)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.font = .preferredFont(forTextStyle: fontStyle)
        button.layer.cornerRadius = 6
        return button
    }
}

extension ProfileHeaderCollectionReusableView: ViewModelConfigurable {
    func configure(with viewModel: ViewModel) {
        guard let viewModel = viewModel as? ProfileHeaderViewModel
        else { return }
        // TODO: Decide whether to pass in the viewModel, or to store it.
        self.viewModel = viewModel
        
        followersButton.subtitleLabel?.text = viewModel.followerCount .intStringValue
        followingButton.subtitleLabel?.text = viewModel.followingCount.intStringValue
        
        if let avatarURL = viewModel.avatarImageURL {
            avatarImageView.sd_setImage(with: avatarURL)
        } else {
            avatarImageView.image = Asset.test.image
        }
        
        switch viewModel.profileStyle {
            case .isFollowing:
                primaryButton.backgroundColor = .secondarySystemBackground
                primaryButton.setTitle(L10n.unfollow, for: .normal)
            case .isNotFollowing:
                primaryButton.backgroundColor = .systemPink
                primaryButton.setTitle(L10n.follow, for: .normal)
            case .isLoggedInUser:
                primaryButton.backgroundColor = .secondarySystemBackground
                primaryButton.setTitle(L10n.editProfile, for: .normal)
        }
    }
}
