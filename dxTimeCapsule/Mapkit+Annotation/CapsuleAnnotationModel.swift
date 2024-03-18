import MapKit

class CapsuleAnnotationModel: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var friends: [Friend]? // 여기서는 태그된 친구들의 정보를 저장
    var info: TimeBox
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, info: TimeBox, friends: [Friend]?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.info = info
        self.friends = friends
    }
    
}

