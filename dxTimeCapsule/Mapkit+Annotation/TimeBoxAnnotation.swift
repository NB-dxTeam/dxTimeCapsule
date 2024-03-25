//
//  TimeBoxAnnotation.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/19/24.
//

import UIKit
import MapKit
import SnapKit


class TimeBoxAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var timeBoxAnnotationData: TimeBoxAnnotationData?
        
    init(coordinate: CLLocationCoordinate2D, timeBoxAnnotationData: TimeBoxAnnotationData) {
        self.coordinate = coordinate
        self.timeBoxAnnotationData = timeBoxAnnotationData
    }
}
