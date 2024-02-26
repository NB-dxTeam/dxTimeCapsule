import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel {
    let db = Firestore.firestore()

    // 이메일을 기준으로 사용자를 검색하는 함수
    func searchUser(byEmailOrNickname query: String, completion: @escaping ([User]) -> Void) {
        db.collection("users").whereField("email", isEqualTo: query).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error searching user: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var users: [User] = []
            snapshot?.documents.forEach { document in
                let user = User(document: document)
                users.append(user)
            }
            completion(users)
        }
    }
    
    // 친구 요청을 보내는 함수
    func sendFriendRequest(toUserId userId: String, fromUser currentUser: User) {
        let friendRequest: [String: Any] = [
            "fromUserId": currentUser.id,
            "toUserId": userId,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("friendRequests").addDocument(data: friendRequest) { error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
            } else {
                print("Friend request sent successfully.")
            }
        }
    }
    
    // 현재 사용자의 친구 목록을 조회하는 함수
    func fetchFriendsList(forUserId userId: String, completion: @escaping ([User]) -> Void) {
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists, let friendIds = document.get("friends") as? [String] {
                var friends: [User] = []
                let group = DispatchGroup()
                
                friendIds.forEach { friendId in
                    group.enter()
                    self.db.collection("users").document(friendId).getDocument { (friendDoc, error) in
                        if let friendDoc = friendDoc, friendDoc.exists {
                            let friend = User(document: friendDoc)
                            friends.append(friend)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(friends)
                }
            } else {
                print("No friends found or error fetching friends list.")
                completion([])
            }
        }
    }
}
