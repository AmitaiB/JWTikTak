//
//  ExploreBannerCollectionViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit
import Reusable
import SnapKit

class ExploreHashtagCollectionViewCell: UICollectionViewCell, Reusable, ViewModelConfigurable
{
    private let iconImageView: UIImageView = {
        let imageView           = UIImageView()
        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let hashtagLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    private func setupContentView() {
        contentView.clipsToBounds = true
        contentView.addSubviews([iconImageView, hashtagLabel])
        contentView.layer.cornerRadius  = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .systemGray5
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(contentView.height * 0.50)
            make.left.equalToSuperview().offset(40)
            make.left.centerY.equalToSuperview()
        }
        
//        hashtagLabel.sizeToFit()
        hashtagLabel.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview().offset(5)
            make.left.equalTo(iconImageView.snp.right).offset(10)
        }
        
        contentView.bringSubviewToFront(hashtagLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        hashtagLabel.text   = nil
    }
    
    func configure(with viewModel: ViewModel) {
        guard let viewModel = viewModel as? ExploreHashtagViewModel else { return }
        iconImageView.image = viewModel.icon
        hashtagLabel.text = viewModel.text + " - count: \(viewModel.count)"
    }
}
