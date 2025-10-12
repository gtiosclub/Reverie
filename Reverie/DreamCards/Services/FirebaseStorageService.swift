//
//  FirebaseStorageService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/9/25.
//

import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    func uploadSticker(
        _ image: UIImage,
        forUserID userID: String,
        dreamID: String
    ) async throws -> URL {
        guard let imageData = image.pngData() else {
            throw ImageProcessingErrorService.failedToGetCGImage
        }
        
        let imagePath = "dream_stickers/\(userID)/\(dreamID).png"
        let imageRef = storage.child(imagePath)
        
        _ = try await imageRef.putDataAsync(imageData)
        
        var attempts = 0
        while attempts < 3 {
            do {
                let downloadURL = try await imageRef.downloadURL()
                return downloadURL
            } catch {
                attempts += 1
                if attempts == 3 {
                    print("❌ All retry attempts failed. Throwing the final error.")
                    throw error
                }
                
                print("⚠️ Download URL not ready, retrying in 0.5s... (Attempt \(attempts))")
                try await Task.sleep(for: .milliseconds(500))
            }
        }
        
        throw ImageProcessingErrorService.uploadFailedAfterRetries
    }
    
    func saveImageURL(_ url: URL, forUserID userID: String) {
        let userRef = db.collection("users").document(userID)
        
        userRef.updateData(["profileImageURL": url.absoluteString]) { error in
            if let error = error {
                print("Error saving URL to Firestore: \(error)")
            } else {
                print("✅ Profile image URL saved to user's document.")
            }
        }
    }
}

