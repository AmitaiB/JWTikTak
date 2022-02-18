//
//  Foundation+Extensions.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/17/22.
//

import Foundation

extension DateFormatter {
    static let `default`: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    static func date(with date: Date) -> String {
        DateFormatter.default.string(from: date)
    }
}
