import Foundation
import FirebaseFirestore

struct TimeCapsule {
    var TimeCapsuleId: String // 타임캡슐 고유 ID
    var uid: String // 타임박스를 생성한 사용자의 ID
    var userName : String // 타임박스를 생성한 사용자의 useName
    var tcBoxImageURL: String? // 업로드 장소 이미지 사진의 URL
    var timeCapsuleImageURL: String? // 업로드된 사진의 URL
    var gpslocation: GeoPoint // gps위치
    var userLocation: String? // 사용자 위치 정보(직접 입력)
    var userComment: String? // 사용자 코멘트
    var userMood: String // 선택된 기분
    var tagFriend: [String]? // 친구 태그 배열
    var createTimeCapsuleDate: Date // 생성일
    var openTimeCapsuleDate: Date // 개봉일
    var isOpened: Bool //개봉여부
}
