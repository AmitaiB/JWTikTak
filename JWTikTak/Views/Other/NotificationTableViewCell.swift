//
//  NotificationTableViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/10/22.
//

import UIKit
import Reusable
import SnapKit

protocol NotificationTableViewCellDelegate: AnyObject {
    func notificationTableViewCell(_ cell: NotificationTableViewCell, didTapFollowFor username: String)
    func notificationTableViewCell(_ cell: NotificationTableViewCell, didTapAvatarFor username: String)
    func notificationTableViewCell(_ cell: NotificationTableViewCell, didTapThumbnailFor postId: String)
}

class NotificationTableViewCell: UITableViewCell, Reusable {
    weak var delegate: NotificationTableViewCellDelegate?
    
    public var model: Notification? {
        didSet { configureForModel() }
    }
    
    private var type: CellType? {
        guard let cellTypeRaw = model?.type.id
        else { return nil }
        
        return CellType(rawValue: cellTypeRaw)
    }
    
    enum CellType: String {
        case postLike
        case userFollow
        case postComment
    }
    
    private let primaryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius  = 25 // iconSize is 50.
        imageView.contentMode         = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor     = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var followButton = FollowButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        let subviews = [primaryImageView, label, dateLabel, followButton]
        contentView.addSubviews(subviews)
        selectionStyle = .none
        
        followButton.addTarget(self, action: #selector(didTapFollow(_:)), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        primaryImageView.addGestureRecognizer(gesture)
        primaryImageView.isUserInteractionEnabled = true
    }
       
    @objc
    private func didTapFollow(_ sender: FollowButton) {
        guard let modelType = self.model?.type
        else { return }
        
        switch modelType {
            case .userFollow(let username):
                delegate?.notificationTableViewCell(self, didTapFollowFor: username)
                sender.toggleState()
            default: break
        }
    }

    @objc
    private func didTapImageView() {
        guard let modelType = self.model?.type
        else { return }
        
        switch modelType {
            case .postLike(let postId), .postComment(let postId):
                delegate?.notificationTableViewCell(self, didTapThumbnailFor: postId)
            case .userFollow(let username):
                delegate?.notificationTableViewCell(self, didTapAvatarFor: username)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize = 50
        primaryImageView.snp.makeConstraints { make in
            make.width.height.equalTo(iconSize)
            make.left.top.equalToSuperview().offset(10)
        }
                
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(primaryImageView.snp.right).offset(10)
            make.bottom.equalTo(label.superview!.snp.centerY)
            make.right.equalTo(label.superview!.snp.right).offset(10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalTo(label)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(dateLabel.superview!.snp.centerY).offset(2)
        }
        
        accessoryView = followButton
        followButton.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        primaryImageView.image = nil
        label.text             = nil
        dateLabel.text         = nil
        followButton.isHidden  = true
        followButton.resetButtonStateForReuse()
    }
    
    private func configureForModel() {
        // TODO: Database call to get actual image

        guard let model = model else { return }

        primaryImageView.image = Asset.creator1.image // TODO: replace/holder
        label.text             = model.text
        dateLabel.text         = .date(with: model.date)
        followButton.isHidden  = type != .userFollow
    }
}
