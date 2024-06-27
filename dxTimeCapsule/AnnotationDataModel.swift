//
//  Annotation.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 6/24/24.
//

import Foundation
import MapKit

struct TimeBoxAnnotationData {
    var timeBox: TimeBox
    var friendsInfo: [User]
}

class TimeBoxAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var timeBoxAnnotationData: TimeBoxAnnotationData?
        
    init(coordinate: CLLocationCoordinate2D, timeBoxAnnotationData: TimeBoxAnnotationData) {
        self.coordinate = coordinate
        self.timeBoxAnnotationData = timeBoxAnnotationData
    }
}
