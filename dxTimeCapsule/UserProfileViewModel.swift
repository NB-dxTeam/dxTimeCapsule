//
//  UserProfileViewModel.swift
//  dxTimeCapsule
//
//  Created by Lee HyeKyung on 2024/02/26.
//

import FirebaseAuth
import FirebaseFirestore

class UserProfileViewModel {
    private var user: User?
    
    // 사용자 계정을 삭제하는 메서드
    func deleteUserAccount(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        // Firestore에서 사용자 데이터 삭제
        let usersCollection = Firestore.firestore().collection("users")
        usersCollection.document(currentUser.uid).delete { error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            // Authentication에서 사용자 삭제
            currentUser.delete { error in
                completion(error == nil)
            }
        }
    }
}


