import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel {
    let db = Firestore.firestore()
    
    // 친구 검색 (닉네임 기준 영어 2글자만 입력해도 검색되게)
    func searchUsersByUsername(username: String, completion: @escaping ([User]?, Error?) -> Void) {
        
        // 검색어의 첫 글자를 대문자로 변환합니다.
        let firstLetter = username.prefix(1).uppercased()
        let remainingString = username.dropFirst().lowercased()
        let searchQuery = firstLetter + remainingString
        
        let query = db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchQuery)
            .whereField("username", isLessThan: searchQuery + "\u{f8ff}")
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }
            
            let users: [User] = documents.compactMap { doc in
                var user = User(uid: doc.documentID, email: "", username: "", profileImageUrl: nil)
                user.uid = doc.get("uid") as? String ?? ""
                user.username = doc.get("username") as? String ?? ""
                user.profileImageUrl = doc.get("profileImageUrl") as? String
                user.email = doc.get("email") as? String ?? ""
                print("user: \(user)")
                return user
            }
            
            completion(users, nil)
        }
    }
    
    // 친구 상태 확인
    func checkFriendshipStatus(forUser userId: String, completion: @escaping (String) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion("사용자 인증 실패")
            return
        }
        let currentUserID = currentUser.uid
        
        // 친구 요청 상태 확인
        db.collection("friendRequests").whereField("senderUid", isEqualTo: currentUserID).whereField("receiverUid", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents, !documents.isEmpty {
                completion("요청 보냄")
                return
            }
            
            // 친구 요청 받음 상태 확인
            self.db.collection("friendRequests").whereField("senderUid", isEqualTo: userId).whereField("receiverUid", isEqualTo: currentUserID).getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents, !documents.isEmpty {
                    completion("요청 받음")
                    return
                }
                
                // 이미 친구인지 확인
                self.db.collection("friendships").whereField("userUids", arrayContains: currentUserID).getDocuments { (snapshot, error) in
                    if let documents = snapshot?.documents {
                        for document in documents {
                            let userUids = document.get("userUids") as? [String] ?? []
                            if userUids.contains(userId) {
                                completion("이미 친구입니다")
                                return
                            }
                        }
                    }
                    completion("친구 추가")
                }
            }
        }
    }
    
    // 친구 요청 보내기
    func sendFriendRequest(toUser targetUserId: String, fromUser currentUserId: String, completion: @escaping (Bool, Error?) -> Void) {
        let friendRequestRef = db.collection("friendRequests").document()
        friendRequestRef.setData([
            "senderUid": currentUserId,
            "receiverUid": targetUserId,
            "requestDate": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // 친구 요청 수락하기
    func acceptFriendRequest(fromUser targetUserId: String, forUser currentUserId: String, completion: @escaping (Bool, Error?) -> Void) {
        let batch = db.batch()
        
        // 친구 관계 생성
        let friendshipRef = db.collection("friendships").document()
        batch.setData([
            "userUids": [currentUserId, targetUserId],
            "acceptedDate": Timestamp(date: Date())
        ], forDocument: friendshipRef)
        
        // 친구 요청 삭제
        db.collection("friendRequests").whereField("senderUid", isEqualTo: targetUserId).whereField("receiverUid", isEqualTo: currentUserId).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                for document in documents {
                    let friendRequestRef = self.db.collection("friendRequests").document(document.documentID)
                    batch.deleteDocument(friendRequestRef)
                }
                
                // batch 작업 커밋
                batch.commit { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
}


