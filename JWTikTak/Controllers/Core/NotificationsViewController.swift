//
//  NotificationsViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import SnapKit
import ProgressHUD
import Reusable

class NotificationsViewController: UIViewController {
    var notifications = [Notification]()
    
    
    private let noNotificationsLabel: UILabel = {
       let label = UILabel()
        label.isHidden      = true
        label.textColor     = .secondaryLabel
        label.text          = "No Notifications"
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "replace me with Reusable")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews([tableView, noNotificationsLabel])
        view.backgroundColor = .systemBackground

        tableView.delegate   = self
        tableView.dataSource = self
//        tableView.register(cellType: NotificationsUserFollowTableViewCell.self)
//        tableView.register(cellType: NotificationsPostLikeTableViewCell.self)
//        tableView.register(cellType: NotificationsPostCommentTableViewCell.self)
        tableView.register(cellType: NotificationTableViewCell.self)
        fetchNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        noNotificationsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
    }
    
    @MainActor
    private func fetchNotifications() {
        ProgressHUD.show()
        
        DatabaseManager.shared.getNotifications { [weak self] in
            switch $0 {
                case .failure(let error):
                    print(error.localizedDescription)
                    ProgressHUD.showFailed()
                case .success(let fetchedNotifications):
                    self?.notifications = fetchedNotifications
                    self?.updateUI()
                    ProgressHUD.showSucceed()
            }
        }
    }
    
    private func updateUI() {
        tableView.isHidden = notifications.isEmpty
        noNotificationsLabel.isHidden = !tableView.isHidden
        
        tableView.reloadData()
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NotificationTableViewCell.self)
        cell.model = model
        return cell
//        switch model.type {
//            case .postLike(let postName):
//                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NotificationsPostLikeTableViewCell.self)
//                cell.configure(with: postName, model: model)
//                return cell
//            case .userFollow(let username):
//                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NotificationsUserFollowTableViewCell.self)
//                cell.configure(with: username, model: model)
//                return cell
//            case .postComment(let postName):
//                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NotificationsPostCommentTableViewCell.self)
//                cell.configure(with: postName, model: model)
//                return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension NotificationsViewController: UITableViewDelegate {
    
}
