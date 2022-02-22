//
//  ExploreBannerCollectionViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit
import Reusable
import SDWebImage

class ExploreUserCollectionViewCell: UICollectionViewCell, Reusable, ViewModelConfigurable {
    private let profilePicImageView: UIImageView = {
        let imageView             = UIImageView()
        imageView.tintColor       = .systemBlue
        imageView.contentMode     = .scaleAspectFit
        imageView.clipsToBounds   = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label  = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 1
        return label
    }()
    
    private let followerCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 8, weight: .thin)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    private func setupContentView() {
        contentView.clipsToBounds = true
        contentView.addSubviews([profilePicImageView, usernameLabel])
        contentView.layer.cornerRadius  = 8
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profilePicImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(usernameLabel.snp.top).offset(10)
        }
        
//        usernameLabel.sizeToFit()
        usernameLabel.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().offset(5)
            make.height.equalTo(40)
        }
        
        contentView.bringSubviewToFront(usernameLabel)
        profilePicImageView.layer.cornerRadius = profilePicImageView.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePicImageView.image = nil
        usernameLabel.text        = nil
    }
    
    func configure(with viewModel: ViewModel) {
        guard let viewModel = viewModel as? ExploreUserViewModel else { return }
        profilePicImageView.sd_setImage(
            with: viewModel.profilePicURL,
            placeholderImage: UIImage(systemName: L10n.SFSymbol.personCircle),
            options: [.continueInBackground])
        
        usernameLabel.text   = viewModel.username
    }
}
