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
        table.register(cellType: SwitchTableViewCell.self)
        return table
    }()

    var viewModel = SettingsViewModel.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.UserSettings.settingsTitle
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
        signOutButton.setTitle(L10n.signOut, for: .normal)
        signOutButton.setTitleColor(.systemRed, for: .normal)
        signOutButton.addTarget(self, action: #selector(didTapSignOutButton), for: .touchUpInside)
        footer.addSubview(signOutButton)
    
        signOutButton.snp.makeConstraints { make in
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
        var cell: UITableViewCell
        
        let cellModel   = viewModel.cellModelForRow(at: indexPath)
        var cellConfig  = UIListContentConfiguration.cell()
        cellConfig.text = cellModel.title

        switch cellModel.title {
            case L10n.UserSettings.saveVideos:
                cell = tableView.dequeueReusableCell(for: indexPath, cellType: SwitchTableViewCell.self)
                let shouldSaveVideos = UserDefaults.standard.bool(forKey: L10n.UserSettings.shouldSaveVideosKey)
                (cell as? SwitchTableViewCell)?.saveVideosSwitch.isOn = shouldSaveVideos
                (cell as? SwitchTableViewCell)?.switchDelegate = self
            
            case L10n.UserSettings.Privacy.string, L10n.UserSettings.Tos.string:
                cell = tableView.dequeueReusableCell(for: indexPath, cellType: PlaceholderCell.self)
                cell.accessoryType = .disclosureIndicator

            default:
                cell = tableView.dequeueReusableCell(for: indexPath, cellType: PlaceholderCell.self)
        }
        
        cell.contentConfiguration = cellConfig
        
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


// MARK: - SwitchTableViewCellDelegate

extension SettingsViewController: SwitchTableViewCellDelegate {
    func switchTableViewCell(_ cell: SwitchTableViewCell, didChangeSwitchValueTo isOn: Bool) {
        // Binds the UI to the underlying value.
        UserDefaults.standard.setValue(isOn, forKey: L10n.UserSettings.shouldSaveVideosKey)
    }
}

class PlaceholderCell: UITableViewCell, Reusable {
    
}
