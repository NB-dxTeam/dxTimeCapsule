import Foundation
import FirebaseFirestore

struct TimeBox {
    var id: String // 타임박스 고유 ID
    var uid: String // 생성한 사용자의 uid
    var userName : String // 생성한 사용자의 닉네임
    var imageURL: [String]? // 타임박스 안의 사진들
    var userLocation: GeoPoint? // 사용자 위치
    var userLocationTitle: String? // 위치 타이틀
    var description: String? // 타임박스 설명
    var tagFriendUid: [String]? // 친구 태그 uid 배열
    var createTimeBoxDate: Timestamp // 생성일
    var openTimeBoxDate: Timestamp // 개봉일
    var isOpened: Bool = false // 개봉여부
    
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
    
    struct Emoji: Identifiable, Hashable {
        let id: String
        let symbol: String
        let description: String
    }
}

struct TimeBoxAnnotationData {
    var timeBox: TimeBox
    var friendsInfo: [Friend]
}
