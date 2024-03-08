import MapKit

class CapsuleAnnotationModel: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var info: CapsuleInfo
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, info: CapsuleInfo) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.info = info
    }
    
}
