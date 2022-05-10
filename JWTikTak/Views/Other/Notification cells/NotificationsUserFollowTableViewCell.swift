//
//  NotificationsUserFollowTableViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/9/22.
//

import UIKit
import Reusable
import SnapKit

class NotificationsUserFollowTableViewCell: UITableViewCell, Reusable {
    
    // avatar, label, follow button
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25 // iconSize is 50.
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

    
    private let followButton: UIButton = {
       let button = UIButton()
        button.setTitle(L10n.follow, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubviews([avatarImageView, label, followButton, dateLabel])
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize = 50
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(iconSize)
            make.left.top.equalToSuperview().offset(10)
        }
        
        followButton.snp.makeConstraints { make in
            make.height.equalTo(iconSize * 0.75)
            make.width.equalTo(iconSize * 1.5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(avatarImageView.snp.right).offset(10)
            make.right.equalTo(followButton.snp.left).offset(10)
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
        avatarImageView.image = nil
        label.text = nil
        dateLabel.text = nil
    }
    
    func configure(with username: String, model: Notification) {
        // TODO: Database call to get actual image
        avatarImageView.image = Asset.creator1.image
        label.text = model.text
        dateLabel.text = .date(with: model.date)
    }
}

