//
//  Errors.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/30/22.
//

import Foundation

/// Errors specific to the `DatabaseManager`.
enum DatabaseError: Error {
    case fetchedValueNil(line: String)
    case cachedUsernameNil
    case cachedUserUidNil
}

/// Errors specific to the `AuthenticationManager`.
enum AuthError: Error {
    case signInFailed
    case userCreationFailed
}

/// Errors specific to the `ExploreDataManager`.
enum ExploreError: Error {
    case path(String)
    case decoding(String)
}
