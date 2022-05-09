//
//  NotificationsViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import SnapKit
import ProgressHUD

class NotificationsViewController: UIViewController {
    var notifications = [MyNotification]()
    
    
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
        // placeholder cells
        let cell = UITableViewCell()
        
        var content = cell.defaultContentConfiguration()
        content.text = "Hello world"
        
        cell.contentConfiguration = content
        
        return cell
    }
}

extension NotificationsViewController: UITableViewDelegate {
    
}
