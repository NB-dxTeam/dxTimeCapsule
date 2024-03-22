/*
    FriendsViewModel.swift 03/21/24 황주영

    친구 관련 데이터 처리를 담당하는 ViewModel입니다.
    Firebase Firestore를 사용하여 친구 관련 기능을 수행합니다.

- 사용자 검색(searchUsersByUserName): 사용자의 닉네임을 기준으로 검색하여 해당하는 사용자를 가져옵니다.
- 친구 상태 확인(checkFriendshipStatus): 두 사용자 간의 친구 관계 상태를 확인합니다.
- 친구 요청 보내기(sendFriendRequest): 한 사용자가 다른 사용자에게 친구 요청을 보냅니다.
- 친구 요청 수락하기(acceptFriendRequest): 친구 요청을 받은 사용자가 해당 요청을 수락합니다.
- 친구 요청 관찰하기(observeFriendRequestsChanges): 특정 사용자 문서에 대한 변경사항을 실시간으로 관찰합니다. (추가) 03/21/24 이혜경
- 친구 요청 목록 가져오기(fetchFriendRequests): 특정 사용자에게 온 친구 요청 목록을 가져옵니다.
- 친구 목록 가져오기(fetchFriends): 특정 사용자의 친구 목록을 가져옵니다.
- 사용자 정보 가져오기(fetchUser): 특정 사용자의 정보를 가져옵니다.
- 여러 사용자 정보 가져오기(fetchUsers): 여러 사용자의 정보를 가져옵니다. (추가) 03/21/24 이혜경
 
*/

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    let db = Firestore.firestore()
    
    
    // 친구 검색 (닉네임 기준 영어 2글자만 입력해도 검색되게)
    func searchUsersByUserName(userName: String, completion: @escaping ([User]?, Error?) -> Void) {
        // 검색어의 첫 글자를 대문자로 변환합니다.
        let firstLetter = userName.prefix(1).uppercased()
        let remainingString = userName.dropFirst().lowercased()
        let searchQuery = firstLetter + remainingString
        
        print("검색 쿼리: \(searchQuery)") // 디버깅 출력

        let query = db.collection("users")
            .whereField("userName", isGreaterThanOrEqualTo: searchQuery)
            .whereField("userName", isLessThan: searchQuery + "\u{f8ff}")
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Firestore에서 사용자 검색 중 에러 발생: \(error.localizedDescription)") // 에러 발생 시 디버깅 출력
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Firestore에서 문서를 찾을 수 없음.") // 문서가 없을 때 디버깅 출력
                completion([], nil)
                return
            }
            
            print("검색된 문서 수: \(documents.count)") // 검색된 문서의 수 디버깅 출력

            let users: [User] = documents.compactMap { doc in
                let data = doc.data()
                return User(
                    uid: doc.documentID, // 문서 ID를 uid로 사용
                    userName: data["userName"] as? String,
                    email: data["email"] as? String,
                    profileImageUrl: data["profileImageUrl"] as? String,
                    friendsUid: data["friendsUid"] as? [String],
                    friends: data["friends"] as? [String: Timestamp],
                    friendRequestsSent: data["friendRequestsSent"] as? [String: Timestamp],
                    friendRequestsReceived: data["friendRequestsReceived"] as? [String: Timestamp]
                )
            }
            
            if users.isEmpty {
                print("검색 결과가 없습니다.") // 검색 결과가 없을 때 디버깅 출력
            } else {
                print("검색된 사용자: \(users)") // 검색된 사용자 디버깅 출력
            }
            
            completion(users, nil)
        }
    }

    
    // 친구 상태 확인 개선
    func checkFriendshipStatus(forUser userId: String, completion: @escaping (String) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion("사용자 인증 실패")
            return
        }
        let currentUserID = currentUser.uid
        print("currentUserID=" + currentUserID)
        
        // 현재 사용자 문서 가져오기
        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let error = error {
                completion("데이터 조회 실패: \(error.localizedDescription)")
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let userData = document.data() else {
                completion("사용자 데이터를 찾을 수 없습니다.")
                print("User data not found.")
                return
            }
            
            // 여기서부터 비동기 작업이 완료된 것으로 간주하고, 디버깅 메시지를 출력합니다.
            print("Debugging: Current user data - \(userData)")
            
            // 비즈니스 로직에 따른 분기 처리
            // 예를 들어, 친구 요청 보낸 상태 확인
            if let friendRequestsSent = userData["friendRequestsSent"] as? [String: Timestamp], friendRequestsSent.keys.contains(userId) {
                completion("요청 보냄")
                print("Friend request sent.")
            } else if let friendRequestsReceived = userData["friendRequestsReceived"] as? [String: Timestamp], friendRequestsReceived.keys.contains(userId) {
                completion("요청 받음")
                print("Friend request received.")
            } else if let friends = userData["friends"] as? [String: String], friends.keys.contains(userId) {
                completion("이미 친구입니다")
                print("Already friends.")
            } else {
                completion("친구 추가")
                print("Can send friend request.")
            }
        }
    }


    
    // 친구 요청 보내기
    func sendFriendRequest(toUser targetUserId: String, fromUser currentUserId: String, completion: @escaping (Bool, Error?) -> Void) {
        let timestamp = Timestamp(date: Date())
        
        let targetUserRef = db.collection("users").document(targetUserId)
        let currentUserRef = db.collection("users").document(currentUserId)
        
        // 대상 사용자의 friendRequestsReceived 업데이트
        targetUserRef.updateData([
            "friendRequestsReceived.\(currentUserId)": timestamp
        ])
        
        // 현재 사용자의 friendRequestsSent 업데이트
        currentUserRef.updateData([
            "friendRequestsSent.\(targetUserId)": timestamp
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
        print("디버깅: 친구 요청 수락 시작")
        let acceptedDate = Timestamp(date: Date())
        let currentUserRef = db.collection("users").document(currentUserId)
        let targetUserRef = db.collection("users").document(targetUserId)
        
        let batch = db.batch()
        
        print("디버깅: 서로의 친구 목록에 추가하는 작업 추가")
        // 서로의 친구 목록에 추가
        batch.updateData([
            "friends.\(targetUserId)": acceptedDate
        ], forDocument: currentUserRef)
        
        batch.updateData([
            "friends.\(currentUserId)": acceptedDate
        ], forDocument: targetUserRef)
        
        print("디버깅: 친구 요청 정보 삭제 작업 추가")
        // 친구 요청 정보 삭제
        
        batch.updateData([
            "friendRequestsSent.\(currentUserId)": FieldValue.delete(),
            "friendRequestsReceived.\(targetUserId)": FieldValue.delete()
        ], forDocument: currentUserRef)

        batch.updateData([
            "friendRequestsReceived.\(targetUserId)": FieldValue.delete(),
            "friendRequestsSent.\(currentUserId)": FieldValue.delete()
        ], forDocument: targetUserRef)
        
        print("디버깅: 배치 작업 커밋")
        batch.commit { error in
            if let error = error {
                print("디버깅: 배치 작업 실패 - \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("디버깅: 배치 작업 성공")
                completion(true, nil)
            }
        }
    }

    
    // 친구 요청 관찰하기
    func observeFriendRequestsChanges(forUser userId: String, completion: @escaping ([String: Timestamp]?) -> Void) {
        let userDocRef = Firestore.firestore().collection("users").document(userId)
        
        userDocRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot, error == nil else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let friendRequestsReceived = document.get("friendRequestsReceived") as? [String: Timestamp] {
                completion(friendRequestsReceived)
            } else {
                completion(nil)
            }
        }
    }


    // 친구 요청 목록 가져오기
    func fetchFriendRequests(forUser userId: String, completion: @escaping ([User]?, Error?) -> Void) {
        db.collection("users").document(userId).getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = document.data(),
                  let friendRequestsReceived = data["friendRequestsReceived"] as? [String: Timestamp] else {
                completion(nil, error ?? NSError(domain: "DataNotFound", code: -1, userInfo: nil))
                return
            }
            
            let userIds = Array(friendRequestsReceived.keys)
            self.fetchUsers(userIds: userIds, completion: completion)
        }
    }

    
    func fetchFriends(forUser userId: String, completion: @escaping ([User]?, Error?) -> Void) {
        db.collection("users").document(userId).getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = document.data(),
                  let friends = data["friends"] as? [String: Timestamp] else {
                completion(nil, error ?? NSError(domain: "DataNotFound", code: -1, userInfo: nil))
                return
            }
            
            let userIds = Array(friends.keys)
            self.fetchUsers(userIds: userIds, completion: completion)
        }
    }

    
    func fetchUser(with userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists, error == nil else {
                completion(nil)
                return
            }

            
            let data = document.data()
            let user = User(
                uid: userId,
                userName: data?["userName"] as? String ?? "",
                email: data?["email"] as? String ?? "",
                profileImageUrl: data?["profileImageUrl"] as? String,
                friends: data?["friends"] as? [String: Timestamp] ?? [:] ,
                friendRequestsSent: data?["friendRequestsSent"] as? [String: Timestamp] ?? [:] ,
                friendRequestsReceived: data?["friendRequestsReceived"] as? [String: Timestamp] ?? [:]
            )
            completion(user)
        }
    }
    
    func fetchUsers(userIds: [String], completion: @escaping ([User]?, Error?) -> Void) {
        let group = DispatchGroup()
        var users: [User] = []
        var fetchError: Error?

        for userId in userIds {
            group.enter()
            fetchUser(with: userId) { user in
                if let user = user {
                    users.append(user)
                } else {
                    fetchError = NSError(domain: "DataFetchError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user data for userId: \(userId)"])
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = fetchError {
                completion(nil, error)
            } else {
                completion(users, nil)
            }
        }
    }

    
}
