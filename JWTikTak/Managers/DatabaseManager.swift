//
//  DatabaseManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseDatabase

/// The Firebase db manager (for 'spreadsheet' data, such as users etc.).
final class DatabaseManager {
    // Singleton
    public static let shared = DatabaseManager()
    private init() {}
    
    private let database = Database.database().reference()
    
    // Public
    
    public func getAllUsers(completion: ([String]) -> Void) {
        
    }
}
