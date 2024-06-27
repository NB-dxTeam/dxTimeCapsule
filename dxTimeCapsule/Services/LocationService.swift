//
//  LocationService.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 6/26/24.
//

import Foundation
import CoreLocation


class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    func setupLocationManager() {
        locationManager.delegate = self
        // 배터리에 맞게 권장되는 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 사용자 위치 권한 요청
        locationManager.requestWhenInUseAuthorization()
        // 위치 업데이트
        locationManager.startUpdatingLocation()
    }
}
