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
                if let document = document, document.exists, let data = document.data() {
                    self?.uid = data["uid"] as? String
                    self?.email = data["email"] as? String
                    self?.nickname = data["userName"] as? String  // userName으로 필드 이름이 변경된 것을 반영
                    self?.profileImageUrl = data["profileImageUrl"] as? String
                    
                    // 여기서는 추가된 필드들을 직접 사용하지 않지만, 필요에 따라 사용할 수 있음
                    // 예: self?.friends = data["friends"] as? [String: String]
                    
                    print("User data fetched successfully")
                } else {
                    // 실패 혹은 사용자 데이터가 없는 경우에 대한 처리
                    self?.uid = "123456"
                    self?.email = "nouser@example.com"
                    self?.nickname = "NO USER"
                    self?.profileImageUrl = "https://example.com/profile/pandaruss.jpg"
                    print("User data not found")
                    print("User data not found, or error fetching user data")
                }
                completion()
                print("document exists: \(document?.exists ?? false)")
            }
        }
    }
}
