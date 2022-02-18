//
//  CommentTableViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import UIKit
import Reusable

class CommentTableViewCell: UITableViewCell, Reusable {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
        
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews([avatarImageView, commentLabel, dateLabel])
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin = 10
        let spacing = 5
        let avatarSide = max(contentView.height * 0.5, 30)

        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(avatarSide)
            make.top.left.equalToSuperview().offset(margin)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(spacing)
            make.top.right.equalToSuperview().offset(spacing)
            make.bottom.equalTo(dateLabel.snp.top)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(commentLabel.snp.left)
            make.bottom.equalToSuperview().offset(-spacing)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.image = nil
        commentLabel.text     = nil
        dateLabel.text        = nil
    }
    
    public func configure(with model: PostComment) {
        commentLabel.text = model.text
        dateLabel.text = .date(with: model.date)
        dateLabel.font = .systemFont(ofSize: 12)
        if let picUrl = model.user.profilePictureURL {
            print(picUrl)
        } else {
            avatarImageView.image = UIImage(systemName: L10n.SFSymbol.personCircle)
        }
    }
}
