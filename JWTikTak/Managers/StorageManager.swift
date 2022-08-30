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
    /// Returns the shared storage manager instance.
    public static let shared = StorageManager()
    private init() {}
    
    private let storageBucket = Storage.storage().reference()
    
    
    // Public
    
    /// Asynchronously uploads a video file to Firebase Storage.
    /// - Parameters:
    ///   - localUrl: A `URL` representing the system file path of the object to be uploaded.
    ///   - filename: The video's filename.
    ///   - completion: The completion handler to call when the upload task is complete; it passes a `Result` that wraps either a `StorageMetadata` object on success, or an error on failure.
    public func uploadVideo(withLocalURL localUrl: URL, filename: String, completion: @escaping (Result<StorageMetadata, Error>) -> Void) {
 
        guard let userUid = DatabaseManager.shared.currentUser?.identifier else {
            // TODO: throw 'not-signed in-error'
            return
        }
        
        // upload video
        storageBucket.child(L10n.Fir.postVideoPathWithUidAndName(userUid, filename))
            .putFile(from: localUrl, metadata: nil) { metaData, error in
                metaData.ifSome { completion(.success($0)) }
                error   .ifSome { completion(.failure($0)) }
            }

        // generate thumbnail
        let asset = AVAsset(url: localUrl)
        let generator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            guard let imageData = UIImage(cgImage: cgImage).pngData()
            else {return}
            
            let thumbnailName = PostModel.getThumbnailFilename(fromVideoFilename: filename)
            let thumbPath = L10n.Fir.postThumbnailPathWithUidAndName(userUid, thumbnailName)
            let metadata = StorageMetadata()
            metadata.contentType = L10n.ContentType.png
            
            storageBucket.child(thumbPath)
                .putData(imageData, metadata: metadata) { _, error in
                    error.ifSome { print($0.localizedDescription)}
                }
        } catch { print(error.localizedDescription) }
    }
    
    /// Asynchronously uploads a `UIImage` (as data) to Firebase Storage, and retrieves a long lived download URL.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - completion: The completion handler to call when the upload task is complete; it passes a `Result` that
    ///   wraps either the `URL` on success, or an error on failure.
    public func uploadProfilePicture(with image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let userUid = DatabaseManager.shared.currentUser?.identifier else {
            // TODO: throw 'not-signed in-error'
            return
        }

        guard let imageData = image.pngData()
        else { return }
        
        let path = "\(L10n.Fir.profilePictures)/uid_\(userUid)/picture.png"
        let metadata = StorageMetadata()
        metadata.contentType = L10n.ContentType.png
        storageBucket.child(path).putData(imageData, metadata: metadata) { _, error in
            error.ifSome { completion(.failure($0)) }
            
            // The happy path is error-free
            guard error.isNone
            else { return }
            
            self.storageBucket.child(path).downloadURL { url, error in
                error.ifSome { completion(.failure($0)) }
                
                guard let downloadUrl = url
                else { return }

                // TODO: Cache non-sensitive data for performance
                completion(.success(downloadUrl))
            }
        }
    }
    
    
    /// Generates a video identifier to be used as a filename.
    /// - Returns: Returns a string created from a UUID, random Int, and the current timestamp, such as “E621E1F8-C36C-495A-93FC-0C247A3E6E5F_666_1660768868”
    public static func generateVideoIdentifier() -> String {
        let uuidString = UUID().uuidString
        let number = Int.random(in: 0...1000)
        let unixTimestamp = Date().timeIntervalSince1970
        
        // TODO: support detecting/handling of mp4
        return "\(uuidString)_\(number)_\(unixTimestamp).mov"
    }
    
    /// Asynchronously retrieves a long lived download URL for a video from the storage provider.
    /// - Parameters:
    ///   - post: The post for which we seek a video URL.
    ///   - completion: The completion handler to call when the fetch is complete; it passes a `Result` that
    ///   wraps either the `URL` on success, or an error on failure.
    func getVideoDownloadURL(forPost post: PostModel, completion: @escaping (Result<URL, Error>) -> Void) {
        
        storageBucket.child(post.videoPath).downloadURL { url, error in
            error.ifSome {completion(.failure($0))}
            url  .ifSome {completion(.success($0))}
        }
    }
    
    /// Asynchronously retrieves a long lived download URL for a thumbnail image from the storage provider.
    /// - Parameters:
    ///   - post: The post for which we seek a thumbnail URL.
    ///   - completion: The completion handler to call when the fetch is complete; it passes a `Result` that
    ///   wraps either the `URL` on success, or an error on failure.
    func getThumbnailDownloadURL(forPost post: PostModel, completion: @escaping (Result<URL, Error>) -> Void) {
        
        storageBucket.child(post.thumbnailPath).downloadURL { url, error in
            error.ifSome {completion(.failure($0))}
            url  .ifSome {completion(.success($0))}
        }
    }
}
