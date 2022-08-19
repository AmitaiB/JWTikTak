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
        // Options, which serve as models for cells in the Settings view controller.
        let saveVideosToggleOption = SettingsOption(title: L10n.UserSettings.saveVideos) {
            // Handled by the cell's UISwitch's observer, not here (tapping the cell itself).
        }
        
        let termsOfServiceOption = SettingsOption(title: L10n.UserSettings.Tos.string, handler: {
            guard let tosURL = URL(string: L10n.UserSettings.Tos.url)
            else { return }
            
            let tosVC = SFSafariViewController(url: tosURL)
            topViewController?.present(tosVC, animated: true)
        })
        
        let privacyPolicyOption = SettingsOption(title: L10n.UserSettings.Privacy.string, handler: {
            guard let privacyURL = URL(string: L10n.UserSettings.Privacy.url)
            else { return }
            
            let privacyVC = SFSafariViewController(url: privacyURL)
            topViewController?.present(privacyVC, animated: true)
        })
        
        // Sections, composed of various options
        let preferencesSection =
        SettingsSection(title: L10n.UserSettings.preferences,
                        options: [saveVideosToggleOption])
        
        let infoSection = SettingsSection(
            title: L10n.UserSettings.information,
            options: [termsOfServiceOption, privacyPolicyOption]
        )
        
        
        // The final model.
        return SettingsViewModel(
            sections:
                [
                    preferencesSection,
                    infoSection,
                ]
        )
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
