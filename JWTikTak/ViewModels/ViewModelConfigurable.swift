//
//  ViewModelConfigurable.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import Foundation

/// Views that consume a `ViewModel`, such as `UITableViewCell`s.
protocol ViewModelConfigurable {
    func configure(with viewModel: ViewModel)
}

/// A trivial protocol, used to explictly signify a member's function call's intention.
protocol ViewModel {}
