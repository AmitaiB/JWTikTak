// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Camera
  internal static let camera = L10n.tr("localizable", "Camera")
  /// Cancel
  internal static let cancel = L10n.tr("localizable", "Cancel")
  /// Yes, Sign Out
  internal static let confirmSignOutMessage = L10n.tr("localizable", "confirmSignOutMessage")
  /// video.mov
  internal static let defaultVideoFilename = L10n.tr("localizable", "defaultVideoFilename")
  /// Edit Profile
  internal static let editProfile = L10n.tr("localizable", "Edit Profile")
  /// Error
  internal static let error = L10n.tr("localizable", "Error")
  /// Explore
  internal static let explore = L10n.tr("localizable", "explore")
  /// Follow
  internal static let follow = L10n.tr("localizable", "Follow")
  /// Followers
  internal static let followers = L10n.tr("localizable", "Followers")
  /// Following
  internal static let following = L10n.tr("localizable", "following")
  /// For You
  internal static let forYou = L10n.tr("localizable", "forYou")
  /// Something went wrong.
  internal static let genericErrorMessage = L10n.tr("localizable", "genericErrorMessage")
  /// Home
  internal static let home = L10n.tr("localizable", "home")
  /// Log me out!
  internal static let logMeOut = L10n.tr("localizable", "LogMeOut")
  /// mp4
  internal static let mp4 = L10n.tr("localizable", "mp4")
  /// Next
  internal static let next = L10n.tr("localizable", "Next")
  /// No Notifications
  internal static let noNotifications = L10n.tr("localizable", "No Notifications")
  /// No Users
  internal static let noUsers = L10n.tr("localizable", "No Users")
  /// Notifications
  internal static let notifications = L10n.tr("localizable", "notifications")
  /// Ooops!
  internal static let ooops = L10n.tr("localizable", "Ooops")
  /// Photos Library
  internal static let photosLibrary = L10n.tr("localizable", "Photos Library")
  /// Post
  internal static let post = L10n.tr("localizable", "Post")
  /// postComment
  internal static let postComment = L10n.tr("localizable", "postComment")
  /// Posting
  internal static let postingMessage = L10n.tr("localizable", "PostingMessage")
  /// postLike
  internal static let postLike = L10n.tr("localizable", "postLike")
  /// Profile
  internal static let profile = L10n.tr("localizable", "profile")
  /// Profile Picture
  internal static let profilePicture = L10n.tr("localizable", "Profile Picture")
  /// Sign Out
  internal static let signOut = L10n.tr("localizable", "Sign Out")
  /// Would you like to sign out?
  internal static let signOutMessage = L10n.tr("localizable", "signOutMessage")
  /// Save Videos
  internal static let saveVideos = L10n.tr("localizable", "Save Videos")
  /// SignOut
  internal static let signOut = L10n.tr("localizable", "SignOut")
  /// Success
  internal static let success = L10n.tr("localizable", "Success")
  /// Unfollow
  internal static let unfollow = L10n.tr("localizable", "Unfollow")
  /// userFollow
  internal static let userFollow = L10n.tr("localizable", "userFollow")

  internal enum ContentType {
    /// image/png
    internal static let png = L10n.tr("localizable", "Content-Type.png")
  }

  internal enum Fir {
    /// Firebase Array Placeholder
    internal static let arrayPlaceholder = L10n.tr("localizable", "FIR.arrayPlaceholder")
    /// FIRAuthStateDidChangeNotification
    internal static let authStateDidChangeNotification = L10n.tr("localizable", "FIR.AuthStateDidChangeNotification")
    /// email
    internal static let email = L10n.tr("localizable", "FIR.email")
    /// posts
    internal static let posts = L10n.tr("localizable", "FIR.posts")
    /// video_thumbnail/uid_%@/%@
    internal static func postThumbnailPathWithUidAndName(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("localizable", "FIR.postThumbnailPathWithUidAndName", String(describing: p1), String(describing: p2))
    }
    /// videos/uid_%@/%@
    internal static func postVideoPathWithUidAndName(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("localizable", "FIR.postVideoPathWithUidAndName", String(describing: p1), String(describing: p2))
    }
    /// posts/%@
    internal static func postWithId(_ p1: Any) -> String {
      return L10n.tr("localizable", "FIR.postWithId", String(describing: p1))
    }
    /// profile_pictures
    internal static let profilePictures = L10n.tr("localizable", "FIR.profilePictures")
    /// users
    internal static let users = L10n.tr("localizable", "FIR.users")
    /// users/%@
    internal static func userWithId(_ p1: Any) -> String {
      return L10n.tr("localizable", "FIR.userWithId", String(describing: p1))
    }
  }

  internal enum Key {
    /// loggedInUsername
    internal static let username = L10n.tr("localizable", "Key.username")
  }

  internal enum Mock {
    /// mixkit-woman-running-vangelis-tiktok-format
    internal static let testVideo = L10n.tr("localizable", "Mock.testVideo")
  }

  internal enum NotificationName {
    internal enum AuthManager {
      /// AuthStateDidChangeNotification
      internal static let authStateDidChange = L10n.tr("localizable", "NotificationName.AuthManager.authStateDidChange")
    }
    internal enum DatabaseManager {
      /// DidAddNewPostNotification
      internal static let didAddNewPost = L10n.tr("localizable", "NotificationName.DatabaseManager.didAddNewPost")
      /// DidUpdateCurrentUserNotification
      internal static let didUpdateCurrentUser = L10n.tr("localizable", "NotificationName.DatabaseManager.didUpdateCurrentUser")
    }
  }

  internal enum SFSymbol {
    /// bell
    internal static let bell = L10n.tr("localizable", "SFSymbol.bell")
    /// camera
    internal static let camera = L10n.tr("localizable", "SFSymbol.camera")
    /// gear
    internal static let gear = L10n.tr("localizable", "SFSymbol.gear")
    /// heart
    internal static let heart = L10n.tr("localizable", "SFSymbol.heart")
    /// heart.fill
    internal static let heartFill = L10n.tr("localizable", "SFSymbol.heartFill")
    /// house
    internal static let house = L10n.tr("localizable", "SFSymbol.house")
    /// magnifyingglass
    internal static let magnifyingglass = L10n.tr("localizable", "SFSymbol.magnifyingglass")
    /// person.circle
    internal static let personCircle = L10n.tr("localizable", "SFSymbol.personCircle")
    /// photo
    internal static let photo = L10n.tr("localizable", "SFSymbol.photo")
    /// photo.circle
    internal static let photoCircle = L10n.tr("localizable", "SFSymbol.photoCircle")
    /// play
    internal static let play = L10n.tr("localizable", "SFSymbol.play")
    /// square.and.arrow.up
    internal static let squareAndArrowUp = L10n.tr("localizable", "SFSymbol.squareAndArrowUp")
    /// square.and.arrow.up.fill
    internal static let squareAndArrowUpFill = L10n.tr("localizable", "SFSymbol.squareAndArrowUpFill")
    /// text.bubble
    internal static let textBubble = L10n.tr("localizable", "SFSymbol.textBubble")
    /// text.bubble.fill
    internal static let textBubbleFill = L10n.tr("localizable", "SFSymbol.textBubbleFill")
  }

  internal enum UserSettings {
    /// Information
    internal static let information = L10n.tr("localizable", "UserSettings.Information")
    /// Preferences
    internal static let preferences = L10n.tr("localizable", "UserSettings.preferences")
    /// Rate App
    internal static let rate = L10n.tr("localizable", "UserSettings.Rate")
    /// Enjoying the app?
    internal static let ratePrompt = L10n.tr("localizable", "UserSettings.RatePrompt")
    /// Save Videos
    internal static let saveVideos = L10n.tr("localizable", "UserSettings.SaveVideos")
    /// Settings
    internal static let settingsTitle = L10n.tr("localizable", "UserSettings.settingsTitle")
    /// Share App
    internal static let share = L10n.tr("localizable", "UserSettings.Share")
    /// kShouldSaveVideos
    internal static let shouldSaveVideosKey = L10n.tr("localizable", "UserSettings.shouldSaveVideosKey")
    internal enum Privacy {
      /// Privacy Policy
      internal static let string = L10n.tr("localizable", "UserSettings.Privacy.string")
      /// https://www.jwplayer.com/legal/privacy
      internal static let url = L10n.tr("localizable", "UserSettings.Privacy.url")
    }
    internal enum Tos {
      /// Terms of Service
      internal static let string = L10n.tr("localizable", "UserSettings.Tos.string")
      /// https://www.jwplayer.com/legal/tos
      internal static let url = L10n.tr("localizable", "UserSettings.Tos.url")
    }
  }

  internal enum UserUID {
    /// rpXNthkiJmawmhS0G1U2f1ZXUUq2
    internal static let ablickstein = L10n.tr("localizable", "UserUID.ablickstein")
    /// Bx8BTvz9wDdfw4xl6shcYc506rs1
    internal static let amitai = L10n.tr("localizable", "UserUID.amitai")
    /// QV4C5PSGyYcy5WeGTmDgXHAPRxt1
    internal static let johnDoe = L10n.tr("localizable", "UserUID.johnDoe")
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
