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
    
     // 친구 상태를 확인하는 메서드
       func checkFriendshipStatus(forUser userId: String, completion: @escaping (String) -> Void) {
           guard let currentUser = Auth.auth().currentUser else {
               completion("사용자 인증 실패")
               return
           }
           let currentUserID = currentUser.uid
           
           // 현재 사용자의 친구 목록, 보낸 친구 요청 목록, 받은 친구 요청 목록을 가져옴
           db.collection("users").document(currentUserID).getDocument { (document, error) in
               if let document = document, document.exists {
                   let data = document.data()
                   let friends = data?["friends"] as? [String] ?? []
                   let sentRequests = data?["friendRequestsSent"] as? [String] ?? []
                   let receivedRequests = data?["friendRequestsReceived"] as? [String] ?? []
                   
                   if friends.contains(userId) {
                       completion("이미 친구입니다")
                   } else if sentRequests.contains(userId) {
                       completion("요청 보냄")
                   } else if receivedRequests.contains(userId) {
                       completion("요청 받음")
                   } else {
                       completion("친구 추가")
                   }
               } else {
                   print("Document does not exist")
                   completion("친구 추가")
               }
           }
       }
    
     // 친구 요청 보내기
     func sendFriendRequest(toUser targetUserId: String, fromUser currentUserId: String, completion: @escaping (Bool, Error?) -> Void) {
         // 먼저 친구 상태를 확인
         checkFriendshipStatus(forUser: targetUserId) { status in
             if status == "친구 추가" {
                 // 요청 보내기 로직 실행
                 self.updateFriendRequestArrays(targetUserId: targetUserId, currentUserId: currentUserId, completion: completion)
             } else {
                 // 이미 친구이거나 요청을 보냈거나 받은 경우
                 completion(false, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "이미 처리된 요청입니다."]))
             }
         }
     }
     
     
     // 친구 요청 배열 업데이트
        private func updateFriendRequestArrays(targetUserId: String, currentUserId: String, completion: @escaping (Bool, Error?) -> Void) {
            let fromUserRef = db.collection("users").document(currentUserId)
            fromUserRef.updateData([
                "friendRequestsSent": FieldValue.arrayUnion([targetUserId])
            ]) { error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                // 요청 받는 사용자의 friendRequestsReceived 배열 업데이트
                let toUserRef = self.db.collection("users").document(targetUserId)
                toUserRef.updateData([
                    "friendRequestsReceived": FieldValue.arrayUnion([currentUserId])
                ]) { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
     
     
     
     // 친구 요청 수락하기
       func acceptFriendRequest(fromUser targetUserId: String, forUser currentUserId: String, completion: @escaping (Bool, Error?) -> Void) {
           // 동시에 여러 Firestore 업데이트를 처리하기 위해 batch 사용
           let batch = db.batch()
           
           let currentUserRef = db.collection("users").document(currentUserId)
           let targetUserRef = db.collection("users").document(targetUserId)
           
           // 현재 사용자의 친구 목록에 targetUserId 추가
           batch.updateData(["friends": FieldValue.arrayUnion([targetUserId])], forDocument: currentUserRef)
           
           // 타겟 사용자의 친구 목록에 currentUserId 추가
           batch.updateData(["friends": FieldValue.arrayUnion([currentUserId])], forDocument: targetUserRef)
           
           // 현재 사용자의 받은 친구 요청 목록에서 targetUserId 제거
           batch.updateData(["friendRequestsReceived": FieldValue.arrayRemove([targetUserId])], forDocument: currentUserRef)
           
           // 타겟 사용자의 보낸 친구 요청 목록에서 currentUserId 제거
           batch.updateData(["friendRequestsSent": FieldValue.arrayRemove([currentUserId])], forDocument: targetUserRef)
           
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
     





