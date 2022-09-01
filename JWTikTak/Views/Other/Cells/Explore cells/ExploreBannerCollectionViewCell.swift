//
//  ExploreBannerCollectionViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit
import Reusable
import SnapKit

class ExploreBannerCollectionViewCell: UICollectionViewCell, Reusable, ViewModelConfigurable {
    private let imageView: UIImageView = {
        let imageView           = UIImageView()
        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let label: UILabel = {
       let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    private func setupContentView() {
        contentView.clipsToBounds = true
        contentView.addSubviews([imageView, label])
        contentView.layer.cornerRadius  = 8
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
//        label.sizeToFit()
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        contentView.bringSubviewToFront(label)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text      = nil
    }
    
    func configure(with viewModel: ViewModel) {
        guard let viewModel = viewModel as? ExploreBannerViewModel else { return }
        imageView.image = viewModel.image
        label.text      = viewModel.title
    }
}
