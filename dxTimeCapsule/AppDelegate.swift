//
//  AppDelegate.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 2/20/24.
//

import UIKit
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 윈도우 생성
        window = UIWindow(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        
        // 런치 스크린으로 사용할 뷰 컨트롤러 생성
        let launchViewController = LaunchViewController()
         // 루트 뷰 컨트롤러로 설정하고 보이게 함
        window?.rootViewController = launchViewController
        window?.makeKeyAndVisible()
         
        // 약간의 딜레이 후에 메인 화면으로 전환하는 코드
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // 2초 후 실행
            // 메인 뷰 컨트롤러 설정
            self.window?.rootViewController = AuthenticationViewController()
        }
        
        return true
    }
}
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

