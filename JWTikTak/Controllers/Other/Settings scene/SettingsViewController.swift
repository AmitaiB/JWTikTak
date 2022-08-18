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

    var viewModel = SettingsViewModel.standard

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
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        
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
        let actionSheet = UIAlertController(title: L10n.signOut, message: L10n.signOutMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(.init(title: L10n.cancel, style: .cancel))
        actionSheet.addAction(.init(title: L10n.confirmSignOutMessage, style: .destructive, handler: { _ in
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
                    SCLAlertView().showError(L10n.ooops, subTitle: L10n.genericErrorMessage)
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
    // Section data
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sectionModelFor(index: section).options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sectionModelFor(index: section).title
    }

    // Cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PlaceholderCell.self)
        
        let cellModel = viewModel.cellModelForRow(at: indexPath)
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.text = cellModel.title

        cell.contentConfiguration = cellConfig
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = viewModel.cellModelForRow(at: indexPath)
        
        cellModel.handler()
    }
}


// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
}


class PlaceholderCell: UITableViewCell, Reusable {
    
}
