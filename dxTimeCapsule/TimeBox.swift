import Foundation
import FirebaseFirestore

struct TimeBox {
    var id: String? // 타임박스 고유 ID
    var uid: String? // 생성한 사용자의 uid
    var userName : String? // 생성한 사용자의 닉네임
    var thumbnailURL: String? // 썸네일
    var imageURL: [String]? // 타임박스 안의 사진들
    var location: GeoPoint? // 위치(위경도)
    var addressTitle: String? // 주소 타이틀
    var address: String? // 상세 주소
    var description: String? // 타임박스 설명
    var tagFriendUid: [String]? // 친구 태그 uid 배열
    var tagFriendUserName: [String]? // 친구네임 태그
    var createTimeBoxDate: Timestamp? // 생성일
    var openTimeBoxDate: Timestamp? // 개봉일
    var isOpened: Bool? = false // 개봉여부
}



