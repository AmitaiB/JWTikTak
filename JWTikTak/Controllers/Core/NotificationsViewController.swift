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
        tableView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in
                self?.refreshTable(sender: self?.tableView.refreshControl)
        })
    }
    
    @MainActor
    func refreshTable(sender: UIRefreshControl?) {
        sender?.beginRefreshing()
        
        DatabaseManager.shared.getNotifications { [weak self] in
            switch $0 {
                case .success(let notifications):
                    self?.notifications = notifications
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
            sender?.endRefreshing()
        }
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
        cell.delegate = self
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let model = notifications[indexPath.row]
       
        DatabaseManager.shared.markNotificationAsHidden(withId: model.id) { [weak self] success in
            guard success else {return}
            DispatchQueue.main.async {
                model.isHidden = true
                self?.removeHiddenNotificationsFromDataSource()
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    private func removeHiddenNotificationsFromDataSource() {
        notifications = notifications.filter({ $0.isHidden == false })
    }
}

// MARK: NotificationTableViewCellDelegate
extension NotificationsViewController: NotificationTableViewCellDelegate {
    func notificationTableViewCell(_ cell: NotificationTableViewCell, didTapFollowFor username: String) {
        guard cell.model?.type == .userFollow(username: username)
        else { return }
        
        DatabaseManager.shared.follow(username: username) { result in
            switch result {
                case .success(_):
                    print("Do something here??? \(#function), line \(#line)")
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func notificationTableViewCell(_ cell: NotificationTableViewCell, didTapAvatarFor username: String) {
        guard cell.model?.type == .userFollow(username: username)
        else { return }
        
        let debugUserObj = User(username: username, identifier: "123-ABC")
        let profileVC = ProfileViewController(user: debugUserObj)
        profileVC.title = username.uppercased()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
