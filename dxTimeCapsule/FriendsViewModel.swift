import FirebaseFirestore

class FriendsViewModel {
    private let db = Firestore.firestore()
    
    func searchUsersByNickname(nickname: String, completion: @escaping ([User]?, Error?) -> Void) {
        db.collection("users").whereField("nickname", isEqualTo: nickname)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                let users: [User] = documents.compactMap { doc in
                    var user = User(id: doc.documentID, email: "", nickname: "", profileImageUrl: nil)
                    user.nickname = doc.get("nickname") as? String ?? ""
                    user.profileImageUrl = doc.get("profileImageUrl") as? String
                    return user
                }
                
                completion(users, nil)
            }
    }

}
