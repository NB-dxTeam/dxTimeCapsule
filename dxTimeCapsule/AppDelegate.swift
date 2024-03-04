import UIKit
import NMapsMap
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         FirebaseApp.configure()
         
         let NMFClientId = Bundle.main.infoDictionary?["NMFClientId"] as! String
         NMFAuthManager.shared().clientId = NMFClientId
         
//         if #available(iOS 13, *) {
//             // iOS 13 이상에서는 SceneDelegate에서 화면 설정을 처리합니다.
//         } else {
//             // iOS 12 이하에서만 UIWindow를 사용하여 화면을 설정합니다.
//             window = UIWindow(frame: UIScreen.main.bounds)
//             let rootViewController = LoginViewController()
//             let navigationController = UINavigationController(rootViewController: rootViewController)
//             window?.rootViewController = rootViewController
//             window?.makeKeyAndVisible()
//         }

         return true
     }
     
     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
         guard let windowScene = (scene as? UIWindowScene) else { return }
         let window = UIWindow(windowScene: windowScene)
         
         let rootViewController = LoginViewController()
         let navigationController = UINavigationController(rootViewController: rootViewController)
         window.rootViewController = rootViewController
         
         self.window = window
         window.makeKeyAndVisible()
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
