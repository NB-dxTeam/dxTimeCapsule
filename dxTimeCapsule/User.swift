import Foundation
import FirebaseFirestore

struct User {
    var id: String
    var email: String
    var nickname: String
    var friends: [String] = []
    
    // Firestore 문서로부터 User 인스턴스를 초기화하기 위한 이니셜라이저
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        self.email = document.get("email") as? String ?? ""
        self.nickname = document.get("nickname") as? String ?? ""
    }
}
