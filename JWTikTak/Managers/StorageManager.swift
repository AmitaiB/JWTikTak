//
//  StorageManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseStorage

/// The Firebase storage manager to interface with the Firebase storage bucket (for big files, i.e., videos).
final class StorageManager {
    // Singleton
    public static let shared = StorageManager()
    private init() {}
    
    private let database = Storage.storage().reference()
    
    // Public
    
    public func getVideoURL(with identifier: String, completion: (URL) -> Void) {
        
    }
    
    public func uploadVideoURL(from url: URL) {
        
    }
}
