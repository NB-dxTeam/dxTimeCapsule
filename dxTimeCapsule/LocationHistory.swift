import UIKit
import FirebaseFirestore

struct Location {
    var id: String
    var uid: String
    var name: String
    var description: String
    var coordinates: [GeoPoint]
    var timestamp: Timestamp

    // Firestore 문서로부터 Location 인스턴스를 초기화하는 이니셜라이저
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.coordinates = dictionary["coordinates"] as? [GeoPoint] ?? []
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp()
    }
}
