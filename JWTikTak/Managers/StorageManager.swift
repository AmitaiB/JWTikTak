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
            
            let thumbnailName = PostModel.getThumbnail(fromFilename: filename)
            let thumbPath = L10n.Fir.postThumbnailPathWithUidAndName(userUid, thumbnailName)
            storageBucket.child(thumbPath)
                .putData(imageData)
        } catch { print(error.localizedDescription) }
    }
    
    public func uploadProfilePicture(with image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let userUid = DatabaseManager.shared.currentUser?.identifier else {
            // TODO: throw 'not-signed in-error'
            return
        }

        guard let imageData = image.pngData()
        else { return }
        
        let path = "\(L10n.Fir.profilePictures)/uid_\(userUid)/picture.png"
        storageBucket.child(path).putData(imageData, metadata: nil) { _, error in
            error.ifSome { completion(.failure($0)) }
            
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
    
    ///
    public func generateVideoIdentifier() -> String {
        let uuidString = UUID().uuidString
        let number = Int.random(in: 0...1000)
        let unixTimestamp = Date().timeIntervalSince1970
        
        // TODO: support detecting/handling of mp4
        return "\(uuidString)_\(number)_\(unixTimestamp).mov"
    }
    
    func getVideoDownloadURL(forPost post: PostModel, completion: @escaping (Result<URL, Error>) -> Void) {
        storageBucket.child(post.videoPath).downloadURL { url, error in
            error.ifSome {completion(.failure($0))}
            url  .ifSome {completion(.success($0))}
        }
    }
    
    func getThumbnailDownloadURL(forPost post: PostModel, completion: @escaping (Result<URL, Error>) -> Void) {
        storageBucket.child(post.thumbnailPath).downloadURL { url, error in
            error.ifSome {completion(.failure($0))}
            url  .ifSome {completion(.success($0))}
        }
    }
}
