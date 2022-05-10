//
//  NotificationsUserFollowTableViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/9/22.
//

import UIKit
import Reusable

class NotificationsPostLikeTableViewCell: UITableViewCell, Reusable {
    private let postThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubviews([postThumbnailImageView, label, dateLabel])
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize = 50
        postThumbnailImageView.snp.makeConstraints { make in
            make.width.height.equalTo(iconSize)
            make.left.top.equalToSuperview().offset(10)
        }
                
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(postThumbnailImageView.snp.right).offset(10)
            make.right.equalToSuperview()
            make.bottom.equalTo(label.superview!.snp.centerY)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalTo(label)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(dateLabel.superview!.snp.centerY).offset(2)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postThumbnailImageView.image = nil
        label.text = nil
        dateLabel.text = nil
    }
    
    func configure(with postFilename: String, model: Notification) {
        postThumbnailImageView.image = Asset.test.image
        label.text = model.text
        dateLabel.text = .date(with: model.date)
    }
}
