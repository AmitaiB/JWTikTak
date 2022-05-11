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
    
}

class NotificationTableViewCell: UITableViewCell, Reusable {
    weak var delegate: NotificationTableViewCellDelegate?
    
    var model: Notification? {
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
        label.numberOfLines = 1
        label.textColor     = .secondaryLabel
        return label
    }()
    
    private var followButton: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.follow, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor     = .systemBlue
        button.layer.cornerRadius  = 6
        button.layer.masksToBounds = true
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        let subviews = [primaryImageView, label, dateLabel, followButton]
        contentView.addSubviews(subviews)
        selectionStyle = .none
        
        followButton.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer { [weak self] in
            self?.didTapImageView()
        }
        primaryImageView.isUserInteractionEnabled = true
        primaryImageView.addGestureRecognizer(gesture)
    }
       
    @objc
    private func didTapFollow() {
        guard let modelType = self.model?.type
        else { return }
        
        switch modelType {
            case .userFollow(let username):
                delegate?.notificationTableViewCell(self, didTapFollowFor: username)
            default: break
        }
    }

    
    private func didTapImageView() {
        guard let modelType = self.model?.type
        else { return }
        
        switch modelType {
            case .postLike(let postName): break
                // thumbnail
            case .userFollow(let username): break
                // avatar
            case .postComment(let postName): break
                // thumbnail
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

            // conditionally add a right constraint.
            let rightAnchor = followButton.isHidden ? label.superview!.snp.right : followButton.snp.left
            make.right.equalTo(rightAnchor).offset(10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalTo(label)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(dateLabel.superview!.snp.centerY).offset(2)
        }
        
        followButton.snp.makeConstraints { make in
            make.height.equalTo(iconSize * 0.75)
            make.width.equalTo(iconSize * 1.5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        primaryImageView.image = nil
        label.text             = nil
        dateLabel.text         = nil
        followButton.isHidden  = true
    }
    
    private func configureForModel() {
        // TODO: Database call to get actual image

        guard let model = model else { return }

        primaryImageView.image = Asset.creator1.image
        label.text             = model.text
        dateLabel.text         = .date(with: model.date)
        followButton.isHidden  = type != .userFollow
    }
}
