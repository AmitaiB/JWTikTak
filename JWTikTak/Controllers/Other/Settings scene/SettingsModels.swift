//
//  SettingsModels.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 8/18/22.
//

import Foundation

struct SettingsSection {
    let title: String
    let options: [SettingsOption]
}

/// The model for the Settings menu items, and therefore, for populating its cells.
struct SettingsOption {
    let title: String
    let handler: (() -> Void)
}
