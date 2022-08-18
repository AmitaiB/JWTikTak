//
//  SettingsViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Reusable
import SnapKit
import SCLAlertView

class SettingsViewController: UIViewController {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(cellType: PlaceholderCell.self)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate   = self
//        createFooter()
        tableView.addSubview(footer)
        tableView.tableFooterView = footer
    }
    
    lazy var footer: UIView = {
        // Add footer, only needs height as per docs
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        
        // Create and add sign out button to footer
        let signOutButton = UIButton(frame: .zero)
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.systemRed, for: .normal)
        signOutButton.addTarget(self, action: #selector(didTapSignOutButton), for: .touchUpInside)
        footer.addSubview(signOutButton)
    
        signOutButton.snp.makeConstraints { make in
//            make.edges.equalToSuperview().inset(5)
            make.center.equalToSuperview()
        }

        return footer
    }()
    
    @objc @MainActor
    func didTapSignOutButton() {
        let actionSheet = UIAlertController(title: "Sign Out", message: "Would you like to sign out?", preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: "Cancel", style: .cancel))
        actionSheet.addAction(.init(title: "Confirm", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] didSignOut in
                // if signed out, go to the signin scene.
                if didSignOut {
                    let signInVC = SignInViewController()
                    let navVC = UINavigationController(rootViewController: signInVC)
                    navVC.modalPresentationStyle = .fullScreen
                    self?.present(navVC, animated: true)
                    
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.tabBarController?.selectedIndex = 0
                } else {
                    SCLAlertView().showError("Oops!", subTitle: "Something went wrong. Please try again.")
                }
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(view.safeAreaInsets)
        }
    }
}


// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PlaceholderCell.self)
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.text = "Hello World!"
        cell.contentConfiguration = cellConfig
        
        return cell
    }
}


// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
}


class PlaceholderCell: UITableViewCell, Reusable {
    
}
