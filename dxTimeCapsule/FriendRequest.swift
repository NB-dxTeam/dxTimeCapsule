import Foundation
import FirebaseFirestore
import FirebaseAuth

struct FriendRequest: Codable {
    var senderUid: String // 친구 요청을 보낸 사용자의 UID
    var requestDate: Date // 친구 요청 날짜 및 시간
    var receiverUid: String
}
