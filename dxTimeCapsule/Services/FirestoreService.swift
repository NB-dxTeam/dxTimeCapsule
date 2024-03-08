//
//  FirestoreService.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/8/24.
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
    
    /// Uploads an image to Firebase Storage and returns the URL.
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data conversion failed"])))
            return
        }
        
        let imageName = UUID().uuidString
        let imageRef = storageRef.child("time_capsule_images/\(imageName).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve image URL"])))
                }
            }
        }
    }
    
    /// Creates a new time capsule document in Firestore.
    func createTimeCapsule(imageURL: String, userLocation: GeoPoint, locationName: String?, description: String, userComment: String, userMood: String, tagFriends: [String], createTimeCapsuleDate: Date, openTimeCapsuleDate: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        let capsuleData: [String: Any] = [
            "uid": Auth.auth().currentUser?.uid ?? "",
            "userName": Auth.auth().currentUser?.displayName ?? "",
            "imageURL": imageURL,
            "userLocation": userLocation,
            "locationName": locationName ?? "",
            "description": description,
            "userComment": userComment,
            "userMood": userMood,
            "tagFriends": tagFriends,
            "createTimeCapsuleDate": Timestamp(date: createTimeCapsuleDate),
            "openTimeCapsuleDate": Timestamp(date: openTimeCapsuleDate),
            "isOpened": false
        ]
        
        db.collection("time_capsules").addDocument(data: capsuleData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
