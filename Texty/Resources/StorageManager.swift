//
//  StorageManager.swift
//  Texty
//
//  Created by Jeslin Yeoh on 30/12/2021.
//

import Foundation
import FirebaseStorage


final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/jeslinyeoh99-gmail-com_profile_picture.png
     */
    
    // result get String or Error
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload picture to Firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {
            metadata, error in
            
            guard error == nil else {
                // failed
                print("Failed to upload picture to Firebase.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download URL for picture.")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    
    /// Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data,
                                   fileName: String,
                                   completion: @escaping UploadPictureCompletion){
        
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: {
            [weak self] metadata, error in
            
            guard error == nil else {
                // failed
                print("Failed to upload picture (message) to Firebase.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download URL for picture (message).")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL (message photo) returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    
    /// Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileURL: URL,
                                   fileName: String,
                                   completion: @escaping UploadPictureCompletion){
        
        let tempURL = createTemporaryURLforVideoFile(url: fileURL)
        
        storage.child("message_videos/\(fileName)").putFile(from: tempURL, metadata: nil, completion: {
            [weak self] metadata, error in
            
            guard error == nil else {
                // failed
                print("Failed to upload video (message) to Firebase.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download URL for video (message).")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL (message video) returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    
    /*  This function will copy a video file to a temporary location so that it remains accessbile for further handling such as an upload to S3.
         - Parameter url: This is the url of the media item.
         - Returns: Return a new URL for the local copy of the vidoe file.
         */
        func createTemporaryURLforVideoFile(url: URL) -> URL {
            /// Create the temporary directory.
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            /// create a temporary file for us to copy the video to.
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
            /// Attempt the copy.
            do {
                try FileManager().copyItem(at: url.absoluteURL, to: temporaryFileURL)
            } catch {
                print("There was an error copying the video file to the temporary location.")
            }

            return temporaryFileURL as URL
        }
    
    public enum StorageErrors: Error {
        
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void){
        
        let reference = storage.child(path)
        
        reference.downloadURL (completion: { url, error in
            
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        })
        
        
    }
}
