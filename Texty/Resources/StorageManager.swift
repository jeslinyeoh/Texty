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
            metadata, error in
            
            guard error == nil else {
                // failed
                print("Failed to upload picture (message) to Firebase.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download URL for picture (message).")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
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
