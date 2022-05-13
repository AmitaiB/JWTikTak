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
    /// The datasource.
    var notifications = [Notification]()
    
    /// Shown when the datasource is empty.
    private let noNotificationsLabel: UILabel = {
       let label = UILabel()
        label.isHidden      = true
        label.textColor     = .secondaryLabel
        label.text          = L10n.noNotifications
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(cellType: NotificationTableViewCell.self)
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews([tableView, noNotificationsLabel])
        view.backgroundColor = .systemBackground

        tableView.delegate   = self
        tableView.dataSource = self
        
        refreshTable()
        tableView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in
                self?.refreshTable(sender: self?.tableView.refreshControl)
        })
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
    func refreshTable(sender: UIRefreshControl? = nil) {
        sender.ifSome { $0.beginRefreshing() }
        sender.ifNone {   ProgressHUD.show() }
        
        DatabaseManager.shared.getNotifications { [weak self] in
            switch $0 {
                case .success(let fetchedNotifications):
                    self?.notifications = fetchedNotifications
                    self?.reloadUI()
                    sender.ifNone { ProgressHUD.showSuccess() }
                case .failure(let error):
                    print(error.localizedDescription)
                    sender.ifNone { ProgressHUD.showFailed() }
            }
            sender.ifSome { $0.endRefreshing() }
        }
    }
        
    private func reloadUI() {
        tableView.isHidden = notifications.isEmpty
        noNotificationsLabel.isHidden = !tableView.isHidden
        tableView.reloadData()
    }
}


// MARK: UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model     = notifications[indexPath.row]
        let cell      = tableView.dequeueReusableCell(
            for: indexPath, cellType: NotificationTableViewCell.self)
        cell.model    = model
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

// MARK: UITableViewDelegate
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
                    print("SUCCESS — not yet implemented \(#function), line \(#line)")
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func notificationTableViewCell(_ cell: NotificationTableViewCell, didTapAvatarFor username: String) {
        print(#function)
        guard cell.model?.type == .userFollow(username: username)
        else { return }
        
        
        let debugUserObj = User(username: username, identifier: "123-ABC")
        let profileVC = ProfileViewController(user: debugUserObj)
        profileVC.title = username.uppercased()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func notificationTableViewCell(_ cell: NotificationTableViewCell, didTapThumbnailFor postId: String) {
        guard cell.model?.type == .postComment(postName: postId)
                || cell.model?.type == .postLike(postName: postId)
        else { return }
        
        print(#function)
    }
}
