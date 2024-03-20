import Foundation
import FirebaseFirestore

// 구조체 아직 업데이트 안함. 03/20 20:51 황주영
struct TimeBox {
    var id: String? // 타임박스 고유 ID
    var uid: String? // 생성한 사용자의 uid
    var userName : String? // 생성한 사용자의 닉네임
    var thumbnailURL: String? // 썸네일
    var imageURL: [String]? // 타임박스 안의 사진들
    var userLocation: GeoPoint? // 사용자 위치
    var userLocationTitle: String? // 위치 타이틀
    var description: String? // 타임박스 설명
    var tagFriendUid: [String]? // 친구 태그 uid 배열
    var createTimeBoxDate: Timestamp? // 생성일
    var openTimeBoxDate: Timestamp? // 개봉일
    var isOpened: Bool? = false // 개봉여부
   
}

struct TimeBoxAnnotationData {
    var timeBox: TimeBox
    var friendsInfo: [Friend]
}


struct Emoji: Identifiable, Hashable {
    let id: String
    let symbol: String
    let description: String
    
    static let emojis: [Emoji] = [
        Emoji(id: "1", symbol: "🥳", description: "행복"),
        Emoji(id: "2", symbol: "🥰", description: "설레는"),
        Emoji(id: "3", symbol: "😆", description: "즐거운"),
        Emoji(id: "4", symbol: "🥹", description: "감동적인"),
        Emoji(id: "5", symbol: "🙂", description: "평범"),
        Emoji(id: "6", symbol: "🫠", description: "스트레스가 많은"),
        Emoji(id: "7", symbol: "😭", description: "슬픈"),
        Emoji(id: "8", symbol: "😫", description: "짜증"),
        Emoji(id: "9", symbol: "🥵", description: "무더운"),
        Emoji(id: "10", symbol: "🥶", description: "추운"),
        Emoji(id: "11", symbol: "🤒", description: "아픈")
    ]
}

// 테스트 모델 코드 //

struct CapsuleInfo {
    var TimeCapsuleId: String
    var tcBoxImageURL: String?
    var latitude: Double // 위도
    var longitude: Double // 경도
    var userLocation: String?
    var userComment: String?
    var createTimeCapsuleDate: Date // 생성일
    var openTimeCapsuleDate: Date // 개봉일
    var isOpened: Bool //개봉여부
    var friendID: String?
}

struct TCInfo {
    var id: String? //document ID
    var tcBoxImageURL: String?
    var userLocation: String?
    var createTimeCapsuleDate: Date // 생성일
    var openTimeCapsuleDate: Date // 개봉일
}
    

