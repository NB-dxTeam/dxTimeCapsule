import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User: Decodable {
    var uid: String? // uid
    var userName: String? // 닉네임
    var email: String? // 이메일
    var profileImageUrl: String? // 프로필 이미지 URL
    var friends: [String: Date]? // [uid: acceptedDate]
    var friendRequestsSent: [String: Date]? // [receiverUid: sentDate]
    var friendRequestsReceived: [String: Date]? // [senderUid: receivedDate]
}

