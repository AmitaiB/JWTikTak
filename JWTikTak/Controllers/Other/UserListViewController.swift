//
//  UserListViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Reusable
import SnapKit

typealias FollowType = UserListViewController.ListType

class DeleteMeTableViewCell: UITableViewCell, Reusable {}

class UserListViewController: UIViewController {
    let type: ListType
    let user: User
    public var userIds: [String]? {
        type == .followers ? user.followers : user.following
    }

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cellType: DeleteMeTableViewCell.self)
        return tableView
    }()
    
    let emptyTableLabel: UILabel = {
        let label = UILabel()
        label.text          = L10n.noUsers
        label.textAlignment = .center
        label.textColor     = .secondaryLabel
        return label
    }()
    
    enum ListType: String {
        case followers
        case following
    }
    
    
    // MARK: - Init
    
    init(type: ListType, user: User) {
        self.type = type
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        switch type {
            case .followers: title = L10n.followers
            case .following: title = L10n.following
        }
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate   = self
        
        if userIds.isNilOrEmpty {
            view.addSubview(emptyTableLabel)
            emptyTableLabel.sizeToFit()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if userIds.isNilOrEmpty {
            emptyTableLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        } else {
            tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { userIds?.count ?? 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        //TODO: displayName rather than User UID
        cell.textLabel?.text = userIds?[indexPath.row] ?? "None?"
        return cell
    }
}

extension UserListViewController: UITableViewDelegate {
    
}
