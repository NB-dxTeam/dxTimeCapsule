//
//  FirestoreService.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/8/24.
//
//
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()
    
    private init() {}
    
    private let db = Firestore.firestore()
    private let storageRef = Storage.storage().reference()
    
    // MARK: - Upload Image
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("timecapsule_images/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(.failure(UploadError.invalidImageData))
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error ?? UploadError.uploadFailed))
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error ?? UploadError.urlGenerationFailed))
                    return
                }
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    enum UploadError: Error {
        case invalidImageData
        case uploadFailed
        case urlGenerationFailed
    }
    
    
    // MARK: - Create Time Capsule
    func createTimeCapsule(_ capsule: TimeCapsule) {
        let db = Firestore.firestore()
        let capsuleData: [String: Any] = [
            "id": capsule.id,
            "uid": capsule.uid,
            "userName": capsule.userName,
            "imageURL": capsule.imageURL!,
            "userLocation": capsule.userLocation ?? NSNull(),
            "description": capsule.description!,
            "tagFriends": capsule.tagFriendUserName!,
            "createTimeCapsuleDate": Timestamp(date: capsule.createTimeCapsuleDate),
            "openTimeCapsuleDate": Timestamp(date: capsule.openTimeCapsuleDate),
            "isOpened": capsule.isOpened
        ]
        
        db.collection("timecapsules").document(capsule.id).setData(capsuleData) { error in
            if let error = error {
                print("Error saving time capsule: \(error.localizedDescription)")
            } else {
                print("Time capsule successfully saved.")
                // Optionally, navigate back or present a success message to the user
            }
        }
    }
    
}
