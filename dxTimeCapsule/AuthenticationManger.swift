//
//  StorageManger.swift
//  dxTimeCapsule
//
//  Created by Lee HyeKyung on 2024/02/27.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
//import FirebaseFirestoreSwift

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}
    
    private let profileImageCollection = Firestore.firestore().collection("profileImages")
    
    func signOut() {
        try? Auth.auth().signOut()
    }
}
