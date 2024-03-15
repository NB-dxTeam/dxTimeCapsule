//
//  FirestoreDataService.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/15/24.
//

import FirebaseFirestore


class FirestoreDataService {
    
    private let db = Firestore.firestore()
    
    // 사용자의 UID를 기반으로 타임캡슐을 찾고, 태그된 친구의 UID를 가져오는 함수
    func fetchTaggedFriendUIDs(forUserUID userUID: String, completion: @escaping ([String]?) -> Void) {
        db.collection("timeCapsules").whereField("uid", isEqualTo: userUID).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                completion(nil)
                return
            }
            
            let taggedFriendUIDs = documents.flatMap { document in
                // 태그된 친구의 UID 배열을 추출
                return document.data()["tagFriendUid"] as? [String] ?? []
            }
            
            completion(taggedFriendUIDs)
        }
    }
    
    // 태그된 친구의 UID 배열을 기반으로 users 콜렉션에서 친구의 정보를 가져오는 함수
    func fetchFriendsInfo(byUIDs uids: [String], completion: @escaping ([Friend]?) -> Void) {
        db.collection("users").whereField("uid", in: uids).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                completion(nil)
                return
            }
            
            let friendsInfo = documents.compactMap { document -> Friend? in
                let data = document.data()
                guard let uid = data["uid"] as? String,
                      let username = data["username"] as? String,
                      let profileImageUrl = data["profileImageUrl"] as? String else {
                    return nil
                }
                return Friend(id: uid, name: username, profileImageUrl: profileImageUrl)
            }
            
            completion(friendsInfo)
        }
    }
}
