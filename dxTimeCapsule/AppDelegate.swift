import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 설정
        FirebaseApp.configure()
        
        // 메인 윈도우 설정
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // MainTabBarView를 루트 뷰 컨트롤러로 설정
        let mainTabBarView = MainTabBarView()
        
        // 네비게이션 컨트롤러로 래핑하여 네비게이션 바 사용
        let navigationController = mainTabBarView
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
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
    
}
