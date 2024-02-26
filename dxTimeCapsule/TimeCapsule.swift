import Foundation

struct TimeCapsule {
    var timeCapsuleId: String // 타임캡슐 고유 ID
    var Id: String // 타임캡슐을 생성한 사용자의 ID
    var mood: String // 선택된 기분
    var photoUrl: String? // 업로드된 사진의 URL
    var location: String? // 위치
    var userLocation: String? // 사용자 위치 정보(직접 입력)
    var comment: String? // 사용자 코멘트
    var tags: [String]? // 태그 배열
    var openDate: Date // 개봉일
    var creationDate: Date // 생성일
}
