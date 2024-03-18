import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User: Decodable {
    var uid: String? // uid
    var userName: String? // 닉네임
    var email: String? // 이메일
    var profileImageUrl: String? // 프로필 이미지 URL
    var friendsUid: [String]? // 친구 uid 목록
    var friendsUserName: [String]? // 친구 닉네임 목록
    var friendRequestsSent: [String]? // 친구 요청이 전송된 사용자 ID 배열
    var friendRequestsReceived: [String]? // 친구 요청을 받은 사용자 ID 배열
    var friendRequestAcceptedDate: Date? // 친구 요청 수락 날짜
}

struct Friend {
    var uid: String // UID를 id로 사용
    var username: String
    var profileImageUrl: String?
}

struct FriendRequest: Codable {
    var senderUid: String // 친구 요청을 날짜 및 시간
    var receiverUid: String
}

struct Friendship: Codable {
    var user1Uid: String // 친구 관계의 한 사용자의 UID
    var user2Uid: String // 친구 관계의 다른 사용자의 UID
    var acceptedDate: Date // 친구 요청 수락 날짜 및 시간
}
