import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Friendship: Codable {
    var user1Uid: String // 친구 관계의 한 사용자의 UID
    var user2Uid: String // 친구 관계의 다른 사용자의 UID
    var acceptedDate: Date // 친구 요청 수락 날짜 및 시간
}
