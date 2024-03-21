import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    let db = Firestore.firestore()
    
    
    // username -> userName 황주영 03/22
    func searchUsersByUsername(username: String, completion: @escaping ([User]?, Error?) -> Void) {
        // 검색어의 첫 글자를 대문자로 변환합니다.
        let firstLetter = username.prefix(1).uppercased()
        let remainingString = username.dropFirst().lowercased()
        let searchQuery = firstLetter + remainingString
        
        let query = db.collection("users")
            .whereField("userName", isGreaterThanOrEqualTo: searchQuery)
            .whereField("userName", isLessThan: searchQuery + "\u{f8ff}")
        
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
                // User 구조체의 새 이니셜라이저를 사용하여 각 문서로부터 User 인스턴스를 생성합니다.
                return User()
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
    
    // 친구 수락하기
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
    
    // 친구 요청 목록을 가져오는 함수 추가 240319 혜경
    func fetchFriendRequests(forUser userId: String, completion: @escaping ([User]?, Error?) -> Void) {
        db.collection("friendRequests")
            .whereField("receiverUid", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var requests: [User] = []
                guard let documents = snapshot?.documents else {
                    completion([], nil) // 빈 배열 반환
                    return
                }
                
                let group = DispatchGroup()
                
                for document in documents {
                    group.enter() // 작업 시작을 그룹에 알림
                    let senderId = document.get("senderUid") as? String ?? ""
                    self.fetchUser(with: senderId) { user in
                        if let user = user {
                            requests.append(user)
                        }
                        group.leave() // 작업 완료를 그룹에 알림
                    }
                }
                
                group.notify(queue: .main) {
                    completion(requests, nil) // 모든 사용자 정보를 성공적으로 가져온 후 완료 핸들러 호출
                }
            }
    }
    
    // 친구 요청 목록 가져오기
    func friendRequestsList(forUser userId: String, completion: @escaping ([User]?, Error?) -> Void) {
        db.collection("friendRequests")
            .whereField("receiverUid", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var requests: [User] = []
                if let documents = snapshot?.documents {
                    for document in documents {
                        let requestUserId = document.get("senderUid") as? String ?? ""
                        self.fetchUser(with: requestUserId) { user in
                            if let user = user {
                                requests.append(user)
                            }
                            if requests.count == documents.count {
                                completion(requests, nil)
                            }
                        }
                    }
                }
            }
    }
    
    func fetchFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("현재 사용자 ID를 가져올 수 없습니다.")
            return
        }

        let userRef = db.collection("users").document(currentUserID)
        userRef.getDocument { [weak self] documentSnapshot, error in
            guard let self = self, let document = documentSnapshot, document.exists, error == nil else {
                print("사용자 문서를 가져오는 중 오류 발생: \(error?.localizedDescription ?? "알 수 없는 오류")")
                return
            }
            
            if let friendsMap = document.get("friends") as? [String: Timestamp] {
                let friendUIDs = Array(friendsMap.keys)
                self.fetchDetailsForFriends(forUserUIDs: friendUIDs)
            }

        }
    }
    
    // UID 배열을 기반으로 각 친구의 상세 정보를 가져오는 함수로 수정
    private func fetchDetailsForFriends(forUserUIDs userUIDs: [String]) {
        self.friends.removeAll() // 현재 친구 목록 초기화
        let group = DispatchGroup()
        
        for userUID in userUIDs {
            group.enter()
            let friendRef = db.collection("users").document(userUID)
            friendRef.getDocument { [weak self] documentSnapshot, error in
                guard let self = self, let document = documentSnapshot, document.exists, error == nil else {
                    print("친구 문서를 가져오는 중 오류 발생: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    group.leave()
                    return
                }
                
                // User 모델이 Firestore 문서로 초기화 가능하다고 가정
                // 아래 코드는 User 인스턴스를 직접 생성하는 예제입니다.
                // 실제로는 document.data()를 통해 얻은 데이터로부터 User 인스턴스를 생성해야 합니다.
                if let data = document.data() {
                    let user = User(
                        uid: data["uid"] as? String,
                        userName: data["userName"] as? String,
                        email: data["email"] as? String,
                        profileImageUrl: data["profileImageUrl"] as? String,
                        friendsUid: data["friendsUid"] as? [String],
                        friends: data["friends"] as? [String: Timestamp],
                        friendRequestsSent: data["friendRequestsSent"] as? [String],
                        friendRequestsReceived: data["friendRequestsReceived"] as? [String]
                    )
                    DispatchQueue.main.async {
                        self.friends.append(user)
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("모든 친구 상세 정보를 가져오기 완료")
            // 여기에서 UI를 업데이트하거나 추가 작업을 수행할 수 있습니다.
        }
    }

    
    func fetchUser(with userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists, error == nil else {
                completion(nil)
                return
            }
            
            guard let data = document.data() else {
                completion(nil)
                return
            }
            
            let user = User(
                uid: data["uid"] as? String,
                userName: data["userName"] as? String,
                email: data["email"] as? String,
                profileImageUrl: data["profileImageUrl"] as? String,
                friendsUid: data["friendsUid"] as? [String],
                friends: data["friends"] as? [String : Timestamp],
                friendRequestsSent: data["friendRequestsSent"] as? [String],
                friendRequestsReceived: data["friendRequestsReceived"] as? [String]
            )
            
            completion(user)
        }
    }

}

