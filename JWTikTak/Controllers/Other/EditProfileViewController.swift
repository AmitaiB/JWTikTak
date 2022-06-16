//
//  EditProfileViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 6/16/22.
//

import UIKit
import SnapKit

class EditProfileViewController: UIViewController {
    var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "👷‍♂️ Under Construction 🚧"
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.editProfile
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close) {
            self.dismiss(animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        placeholderLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}
