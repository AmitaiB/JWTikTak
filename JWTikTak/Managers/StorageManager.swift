//
//  StorageManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import FirebaseStorage
import AVFoundation

/// The Firebase storage manager to interface with the Firebase storage bucket (for big files, i.e., videos).
final class StorageManager {
    // Singleton
    public static let shared = StorageManager()
    private init() {}
    
    private let storageBucket = Storage.storage().reference()
    
    
    // Public
    
    public func getVideoURL(with identifier: String, completion: (URL) -> Void) {
        
    }
    
    public func uploadVideoURL(from url: URL, filename: String, completion: @escaping (Result<StorageMetadata, Error>) -> Void) {
 
        guard let username = AuthManager.shared.currentUsername else {
            // throw not-signed in-error
            return
        }
        
        storageBucket.child("videos/\(username)/\(filename)")
            .putFile(from: url, metadata: nil) { metaData, error in
                metaData.ifThen { completion(.success($0)) }
                error   .ifThen { completion(.failure($0)) }
            }
    }
    
    ///
    public func generateVideoIdentifier() -> String {
        let uuidString = UUID().uuidString
        let number = Int.random(in: 0...1000)
        let unixTimestamp = Date().timeIntervalSince1970
        
        // TODO: support detecting/handling of mp4
        return "\(uuidString)_\(number)_\(unixTimestamp).mov"
    }
}
