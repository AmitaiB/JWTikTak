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
    
    /// Create a thumbnail for the post cell, generated from the video itself.
    func configure(with viewModel: ViewModel) {
        guard let postModel = viewModel as? PostModel
        else { return }

        StorageManager.shared.getDownloadURL(forPost: postModel) { result in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let postVideoURL):
                    // Generate thumbnail
                    let asset = AVAsset(url: postVideoURL)
                    let generator = AVAssetImageGenerator(asset: asset)
                    do {
                        let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                        self.imageView.image = UIImage(cgImage: cgImage)
                    } catch { print(error.localizedDescription) }
            }
        }
    }
}
