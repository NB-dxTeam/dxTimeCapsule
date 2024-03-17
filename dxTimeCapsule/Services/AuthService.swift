//
//  AuthService.swift
//  dxTimeCapsule
//
//  Created by Lee HyeKyung on 3/14/24.
//

//import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func signUpWithEmail(email: String, password: String, username: String, profileImage: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = authResult?.user.uid else {
                completion(.failure(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            let storageRef = Storage.storage().reference().child("userProfileImages/\(uid).jpg")
            guard let imageData = profileImage.jpegData(compressionQuality: 0.75) else {
                completion(.failure(NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])))
                return
            }
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                storageRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        completion(.failure(error ?? NSError(domain: "AuthService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                        return
                    }
                    
                    let userData = ["email": email, "username": username, "profileImageUrl": downloadURL.absoluteString]
                    Firestore.firestore().collection("users").document(uid).setData(userData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(true))
                        }
                    }
                }
            }
        }
    }
}
