//
//  ViewModelConfigurable.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import Foundation

protocol ViewModelConfigurable {
    func configure(with viewModel: ViewModel)
}

/// Used to explictly signify the function call's intention.
protocol ViewModel {}
