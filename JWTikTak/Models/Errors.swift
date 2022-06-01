//
//  Errors.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 5/30/22.
//

import Foundation

enum DatabaseError: Error {
    case fetchedValueNil(line: String)
    case cachedUsernameNil
    case cachedUserUidNil
}

enum ExploreError: Error {
    case path(String)
    case decoding(String)
}

enum AuthError: Error {
    case signInFailed
    case userCreationFailed
}

