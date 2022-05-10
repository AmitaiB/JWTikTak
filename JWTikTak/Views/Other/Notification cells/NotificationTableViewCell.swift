//
//  NotificationTableViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/10/22.
//

import UIKit
import Reusable
import SnapKit

class NotificationTableViewCell: UITableViewCell, Reusable {
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
    
    // only for userFollow cells
    private var followButton: UIButton? = {
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
        let subviews = [primaryImageView, label, dateLabel, followButton].compactMap{$0}
        contentView.addSubviews(subviews)
        selectionStyle = .none
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
            let rightAnchor = followButton?.snp.left ?? label.superview?.snp.right
            rightAnchor.ifThen { make.right.equalTo($0).offset(10) }
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalTo(label)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(dateLabel.superview!.snp.centerY).offset(2)
        }
        
        guard let followButton = followButton
        else { return }
        
        followButton.snp.makeConstraints { make in
            make.height.equalTo(iconSize * 0.75)
            make.width.equalTo(iconSize * 1.5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        primaryImageView.image = nil
        label.text = nil
        dateLabel.text = nil
    }
    
    private func configureForModel() {
        // TODO: Database call to get actual image

        guard let model = model else { return }

        primaryImageView.image = Asset.creator1.image
        label.text = model.text
        dateLabel.text = .date(with: model.date)
        
        if type != .userFollow {
            followButton = nil
        }
    }
}
