//
//  UserListViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Reusable
import SnapKit


class DeleteMeTableViewCell: UITableViewCell, Reusable {}

class UserListViewController: UIViewController {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cellType: DeleteMeTableViewCell.self)
        return tableView
    }()
    
    enum ListType {
        case followers
        case following
    }
    
    let type: ListType
    let user: User
    
    init(type: ListType, user: User) {
        self.type = type
        self.user = user
        super.init()
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
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
}

extension UserListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 10 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

extension UserListViewController: UITableViewDelegate {
    
}
