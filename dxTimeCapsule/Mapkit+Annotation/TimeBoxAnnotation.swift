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
        var title: String?
        var subtitle: String?
        var timeBoxAnnotationData: TimeBoxAnnotationData?
        
        init(coordinate: CLLocationCoordinate2D, timeBoxAnnotationData: TimeBoxAnnotationData) {
            self.coordinate = coordinate
            self.timeBoxAnnotationData = timeBoxAnnotationData
            //self.title = timeBoxAnnotationData.timeBox.addressTitle
            super.init()
            self.subtitle = createSubtitle()
        }
        
        private func createSubtitle() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy.MM.dd" // 날짜 형식 지정
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대 설정
            dateFormatter.locale = Locale(identifier: "ko_KR") // 로케일을 한국어로 설정
            
            var subtitleParts = [String]()
            
            if let createTime = timeBoxAnnotationData?.timeBox.createTimeBoxDate?.dateValue() {
                subtitleParts.append("생성일: \(dateFormatter.string(from: createTime))")
            }
            
            if let openTime = timeBoxAnnotationData?.timeBox.openTimeBoxDate?.dateValue() {
                subtitleParts.append("개봉일: \(dateFormatter.string(from: openTime))")
            }
            
            return subtitleParts.joined(separator: " ")
        }
}
