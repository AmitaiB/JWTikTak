//
//  PostCollectionViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 6/7/22.
//

import UIKit
import AVFoundation
import Reusable
import SnapKit

class PostCollectionViewCell: UICollectionViewCell, Reusable, ViewModelConfigurable {
    private let imageView: UIImageView = {
        let iView = UIImageView()
        iView.clipsToBounds = true
        iView.contentMode   = .scaleAspectFill
        return iView
    }()
    
    private let overlay: UIView = {
        let view = UIView()
        let playImageView = UIImageView(image: UIImage(systemName: L10n.SFSymbol.play))
        playImageView.tintColor = .white
        view.addSubview(playImageView)
        playImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.sizeToFit()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubviews([imageView, overlay])
        contentView.bringSubviewToFront(overlay)
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        overlay.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    func configure(with viewModel: ViewModel) {
        guard let postModel = viewModel as? PostModel
        else { return }

        StorageManager.shared.getThumbnailDownloadURL(forPost: postModel) { [weak self] result in
            switch result {
                case .success(let thumbnailURL):
                    self?.imageView.sd_setImage(with: thumbnailURL, placeholderImage: .init(named: L10n.SFSymbol.photo))
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}
