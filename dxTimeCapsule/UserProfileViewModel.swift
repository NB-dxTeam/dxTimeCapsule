//
//  UserProfileViewModel.swift
//  dxTimeCapsule
//
//  Created by t2023-m0051 on 2/28/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - UserViewModel
class UserProfileViewModel {

    // Properties to hold the user data
    var uid: String?
    var email: String?
    var nickname: String?
    var profileImageUrl: String?

    // Initialization with default values
    init(uid: String? = nil, email: String? = nil, nickname: String? = nil, profileImageUrl: String? = nil) {
        self.uid = uid
        self.email = email
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
    }

    // Mock method to simulate fetching user data from Firestore
    func fetchUserData(completion: @escaping () -> Void) {
            guard let currentUser = Auth.auth().currentUser else {
                completion()
                return
            }
            let uid = currentUser.uid
            let db = Firestore.firestore()
            let userDocRef = db.collection("users").document(uid)

            userDocRef.getDocument { [weak self] (document, error) in
                DispatchQueue.main.async {
                    if let document = document, document.exists {
                        self?.uid = document.get("uid") as? String
                        self?.email = document.get("email") as? String
                        self?.nickname = document.get("username") as? String
                        self?.profileImageUrl = document.get("profileImageUrl") as? String
                        print("User data fetched successfully")
                    } else {
                        self?.uid = "123456"
                        self?.email = "pandaruss@example.com"
                        self?.nickname = "PANDA RUSS"
                        self?.profileImageUrl = "https://example.com/profile/pandaruss.jpg"
                        print("User data not found")
                    }
                    completion()
                    print("document exists: \(document?.exists ?? false)")
                }
            }
        }
    }
