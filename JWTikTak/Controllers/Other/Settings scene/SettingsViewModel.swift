//
//  SettingsViewModel.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 8/18/22.
//

import Foundation
import SafariServices
import UIKit

struct SettingsViewModel {
    let sections: [SettingsSection]
    
    static var standard: SettingsViewModel {
        let viewModel = SettingsViewModel(
            sections:
                [
                    SettingsSection(
                        title: "Information",
                        options: [
                            SettingsOption(title: "Terms of Service", handler: {
                                guard let tosURL = URL(string: "https://www.jwplayer.com/legal/tos")
                                else { return }
                                
                                let tosVC = SFSafariViewController(url: tosURL)
                                topViewController?.present(tosVC, animated: true)
                            }),
                            SettingsOption(title: "Privacy Policy", handler: {
                                guard let privacyURL = URL(string: "https://www.jwplayer.com/legal/privacy")
                                else { return }
                                
                                let privacyVC = SFSafariViewController(url: privacyURL)
                                topViewController?.present(privacyVC, animated: true)
                            }),
                        ])
                ]
        )
        
        return viewModel
    }
    
    /// Returns the section at the index path you specify.
    func sectionForRow(at indexPath: IndexPath) -> SettingsSection {
        sections[indexPath.section]
    }

    /// Returns the `SettingsOption` to be used as the model for the cell at the index path you specify.
    func cellModelForRow(at indexPath: IndexPath) -> SettingsOption {
        sectionForRow(at: indexPath).options[indexPath.row]
    }
    
    /// Returns the `SettingsSection` for a given sectionIndex (`indexPath.section`, or sometimes just `section`).
    func sectionModelFor(index: Int) -> SettingsSection {
        sections[index]
    }
    
    
    // MARK: helpers
    
    /// Spelunks through architectural assumptions to agnostically present a view controller.
    static var topViewController: UIViewController? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

struct SettingsSection {
    let title: String
    let options: [SettingsOption]
}

/// The model for the Settings menu items, and therefore, for populating its cells.
struct SettingsOption {
    let title: String
    let handler: (() -> Void)
}
