// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Explore
  internal static let explore = L10n.tr("localizable", "explore")
  /// Following
  internal static let following = L10n.tr("localizable", "following")
  /// For You
  internal static let forYou = L10n.tr("localizable", "forYou")
  /// Home
  internal static let home = L10n.tr("localizable", "home")
  /// Notifications
  internal static let notifications = L10n.tr("localizable", "notifications")
  /// Profile
  internal static let profile = L10n.tr("localizable", "profile")

  internal enum SFSymbol {
    /// camera
    internal static let camera = L10n.tr("localizable", "SFSymbol.camera")
    /// text.bubble
    internal static let comment = L10n.tr("localizable", "SFSymbol.comment")
    /// text.bubble.fill
    internal static let commentFill = L10n.tr("localizable", "SFSymbol.commentFill")
    /// magnifyingglass
    internal static let explore = L10n.tr("localizable", "SFSymbol.explore")
    /// house
    internal static let home = L10n.tr("localizable", "SFSymbol.home")
    /// heart
    internal static let like = L10n.tr("localizable", "SFSymbol.like")
    /// heart.fill
    internal static let likeFill = L10n.tr("localizable", "SFSymbol.likeFill")
    /// bell
    internal static let notification = L10n.tr("localizable", "SFSymbol.notification")
    /// person.circle
    internal static let profile = L10n.tr("localizable", "SFSymbol.profile")
    /// square.and.arrow.up
    internal static let share = L10n.tr("localizable", "SFSymbol.share")
    /// square.and.arrow.up.fill
    internal static let shareFill = L10n.tr("localizable", "SFSymbol.shareFill")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
