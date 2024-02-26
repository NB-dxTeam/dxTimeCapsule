import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User {
    var id: String
    var email: String
    var nickname: String
    var friends: [String] = [] // 친구
    var profileImageUrl: String? // 프로필 이미지 URL

    
    // 현재 로그인한 사용자 정보를 가져오는 정적 메서드
    static func getCurrentUser(completion: @escaping (User?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(nil)
            return
        }
        
        let usersCollection = Firestore.firestore().collection("users")
        usersCollection.document(user.uid).getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, error == nil else {
                completion(nil)
                return
            }
            
            let id = user.uid
            let email = user.email ?? ""
            let nickname = document.get("nickname") as? String ?? ""
            let friends = document.get("friends") as? [String] ?? []
            
            let currentUser = User(id: id, email: email, nickname: nickname, friends: friends)
            completion(currentUser)
        }
    }
}
