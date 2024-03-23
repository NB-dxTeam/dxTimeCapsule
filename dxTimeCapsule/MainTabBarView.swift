import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class MainTabBarView: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabs()
        self.delegate = self
        
        // 앱 시작 시 친구 요청을 확인.

        updateFriendRequestBadge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFriendRequestBadge), name: NSNotification.Name("UpdateFriendRequestBadge"), object: nil)

//        // NotificationCenter Observer 추가 - 우경
//        NotificationCenter.default.addObserver(self, selector: #selector(returnToHome), name: NSNotification.Name("ReturnToHome"), object: nil)
    }
    
//    @objc func returnToHome() {
//        // 첫 번째 탭(홈 화면)으로 이동합니다. - 우경
//        self.selectedIndex = 0
//    }
    
    private func setupTabs() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        
        let searchModalTableViewController = UINavigationController(rootViewController: CapsuleMapViewController())
        
        let postUploadNavigationController = UINavigationController(rootViewController: LocationMapkitViewController())

        let notificationViewController = UINavigationController(rootViewController: FriendsRequestViewController())
        
        let profileViewController = UINavigationController(rootViewController: UserProfileViewController())
        
        homeViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Home_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Home_Select", targetSize: CGSize(width: 24, height: 24)))
        homeViewController.tabBarItem.tag = 0
        
        searchModalTableViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Search_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Search_Select", targetSize: CGSize(width: 24, height: 24)))
        searchModalTableViewController.tabBarItem.tag = 1


        
        postUploadNavigationController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Write_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Write_Select", targetSize: CGSize(width: 24, height: 24)))
        postUploadNavigationController.tabBarItem.tag = 2
        
        notificationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Activity_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Activity_Select", targetSize: CGSize(width: 24, height: 24)))
        notificationViewController.tabBarItem.tag = 3

        
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Profile_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Profile_Select", targetSize: CGSize(width: 24, height: 24)))
        profileViewController.tabBarItem.tag = 4


        
        let viewControllers = [homeViewController, searchModalTableViewController, postUploadNavigationController, notificationViewController, profileViewController]
        
        self.viewControllers = viewControllers
        self.tabBar.tintColor = UIColor(hex: "#C82D6B")
        self.tabBar.backgroundColor = .white
    }
    
    func updateNotificationBadge(with count: Int) {
        DispatchQueue.main.async {
            if count > 0 {
                // 친구 요청이 있을 경우, 숫자를 배지에 표시
                self.viewControllers?[3].tabBarItem.badgeValue = "\(count)"
            } else {
                // 친구 요청이 없을 경우, 배지를 숨깁니다.
                self.viewControllers?[3].tabBarItem.badgeValue = nil
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 첫 번째 탭이 선택되었는지 확인합니다.
        if viewController.tabBarItem.tag == 0 {
            // 선택된 뷰 컨트롤러가 UINavigationController인지 확인합니다.
            if let navController = viewController as? UINavigationController {
                // UINavigationController의 루트 뷰 컨트롤러로 돌아갑니다.
                navController.popToRootViewController(animated: false)
                
                // 현재 선택된 탭이 첫 번째 탭이 아닌 경우에만,
                // 첫 번째 탭의 뷰 컨트롤러를 초기 상태로 리셋합니다.
                if tabBarController.selectedIndex != 0 {
                    let newHomeVC = HomeViewController()
                    navController.setViewControllers([newHomeVC], animated: false)
                }

                return true // 첫 번째 탭으로의 이동을 허용합니다.
            }
        } else if viewController.tabBarItem.tag == 2{
            // 태그 2번인 경우, 전체 화면 모달로 LocationMapkitViewController를 표시합니다.
             let locationVC = LocationMapkitViewController()
             locationVC.modalPresentationStyle = .fullScreen // 전체 화면으로 설정
             self.present(locationVC, animated: true, completion: nil)
             return false // 탭 바 컨트롤러에 의한 기본 이동 처리 방지
         }
        // 다른 모든 경우에는 탭 선택을 그대로 진행합니다.
           return true
    }

    func resizeImage(imageName: String, targetSize: CGSize) -> UIImage? {
        guard let image = UIImage(named: imageName) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
    
    @objc func updateFriendRequestBadge() {
        // 현재 로그인한 사용자의 UID를 가져옵니다.
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        // Firestore에서 현재 사용자의 friendRequestsReceived 필드를 조회합니다.
        let db = Firestore.firestore()
        db.collection("users").document(currentUserId).getDocument { [weak self] (document, error) in
            if let error = error {
                // 오류가 발생했을 경우, 콘솔에 오류를 출력합니다.
                print("Error fetching friend requests: \(error)")
                return
            }
            
            if let document = document, document.exists {
                // friendRequestsReceived 필드에서 친구 요청의 수를 가져옵니다.
                let friendRequestsReceived = document.get("friendRequestsReceived") as? [String: Timestamp] ?? [:]
                let friendRequestCount = friendRequestsReceived.count
                
                // 친구 요청의 수를 바탕으로 알림 배지를 업데이트합니다.
                DispatchQueue.main.async {
                    self?.updateNotificationBadge(with: friendRequestCount)
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    

}

