//
//  FirestoreDataService.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/15/24.
//

import FirebaseFirestore

class FirestoreDataService {
    
    private let db = Firestore.firestore()
    
    // 태그된 친구의 UID 배열을 기반으로 users 콜렉션에서 친구의 정보를 가져오는 함수
    func fetchFriendsInfo(byUIDs uids: [String], completion: @escaping ([User]?) -> Void) {
        // uids 배열이 비어 있는지 확인
        guard !uids.isEmpty else {
            print("UIDs array is empty, skipping the query.")
            completion(nil) // 빈 배열이면 콜백 함수를 nil과 함께 바로 호출
            return
        }
        
        db.collection("users").whereField("uid", in: uids).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                completion(nil)
                return
            }
            
            let friendsInfo = documents.compactMap { document -> User? in
                let data = document.data()
                guard let uid = data["uid"] as? String,
                      let userName = data["userName"] as? String,
                      let profileImageUrl = data["profileImageUrl"] as? String else {
                    return nil
                }
                return User(uid: uid, userName: userName, profileImageUrl: profileImageUrl)
            }
            
            completion(friendsInfo)
        }
    }
    
    func fetchTimeBoxs(userId: String, filter: CapsuleFilterButtons, completion: @escaping ([QueryDocumentSnapshot]?) -> Void) {
        var query: Query
        switch filter {
        case .all:
            query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId).order(by: "opentimeBoxDate", descending: false)
        case .locked:
            query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId).whereField("isOpened", isEqualTo: false)
        case .opened:
            query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId).whereField("isOpened", isEqualTo: true)
        }
        
        query.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil)
                return
            }
            completion(documents)
        }
    }
}
