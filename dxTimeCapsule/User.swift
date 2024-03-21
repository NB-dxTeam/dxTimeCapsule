import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User: Decodable {
    var uid: String? // uid
    var userName: String? // 닉네임
    var email: String? // 이메일
    var profileImageUrl: String? // 프로필 이미지 URL
    var friendsUid: [String]? // 친구 uid 목록
    var friends:  [String: Timestamp]? // 친구 닉네임 목록 : 친구 수락날짜
    var friendRequestsSent: [String]? // 친구 요청이 전송된 사용자 ID 배열
    var friendRequestsReceived: [String]? // 친구 요청을 받은 사용자 ID 배열

}

