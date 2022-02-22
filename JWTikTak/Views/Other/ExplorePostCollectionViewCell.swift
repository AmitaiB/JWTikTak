//
//  ExploreBannerCollectionViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit
import Reusable

class ExplorePostCollectionViewCell: UICollectionViewCell, Reusable, ViewModelConfigurable {
    private let thumbnailView: UIImageView = {
        let imageView           = UIImageView()
        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 8, weight: .thin)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    private func setupContentView() {
        contentView.clipsToBounds = true
        contentView.addSubviews([thumbnailView, captionLabel])
        contentView.layer.cornerRadius  = 8
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let thumbCapOffset = contentView.height * 0.75
        
        thumbnailView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(thumbCapOffset)
        }
        
//        captionLabel.sizeToFit()
        captionLabel.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().offset(5)
            make.top.equalTo(thumbnailView.snp.bottom).offset(5)
        }
        
        contentView.bringSubviewToFront(captionLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailView.image = nil
        captionLabel.text   = nil
    }
    
    func configure(with viewModel: ViewModel) {
        guard let viewModel = viewModel as? ExplorePostViewModel else { return }
        thumbnailView.image = viewModel.thumbnailImage
        captionLabel.text   = viewModel.caption
    }
}
