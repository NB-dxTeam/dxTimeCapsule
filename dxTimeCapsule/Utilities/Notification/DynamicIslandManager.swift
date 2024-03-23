//
//  DynamicIslandManager.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/24/24.
//

import Foundation
import UIKit
import UserNotifications

class DynamicIslandNotificationManager {
    static let shared = DynamicIslandNotificationManager()
    
    private init() {}
    
    // 알림 권한 요청
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("알림 권한 승인됨")
            } else if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
            }
        }
    }
    
    // 특정 타임박스에 대한 알림 스케줄링
    func scheduleNotification(for timeBox: TimeBox) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "타임박스 알림!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "\(timeBox.name)가 열렸습니다.", arguments: nil)
        content.sound = UNNotificationSound.default
        
        // 타임박스 개봉 시간에 맞춰 알림을 스케줄링합니다.
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: timeBox.openDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: timeBox.id, content: content, trigger: trigger)
        
        // 알림 센터에 요청 추가
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 스케줄링 실패: \(error.localizedDescription)")
            } else {
                print("알림 스케줄링 성공")
            }
        }
    }
    
    // 사용자가 알림을 탭했을 때의 처리 로직
    func handleNotificationTap(for timeBoxId: String) {
        // TODO: 타임박스 ID를 기반으로 알맞은 화면 또는 데이터로 이동하는 로직 구현
    }
}

// 'TimeBox' 모델이 필요합니다. 이전 단계에서 언급된 `TimeBox.swift` 파일에서 모델을 정의해야 합니다.
