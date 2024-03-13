import UIKit

class MainTabBarView: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabs()
        self.delegate = self
        
        // NotificationCenter Observer 추가 - 우경
        NotificationCenter.default.addObserver(self, selector: #selector(returnToHome), name: NSNotification.Name("ReturnToHome"), object: nil)
    }
    
    @objc func returnToHome() {
        // 첫 번째 탭(홈 화면)으로 이동합니다. - 우경
        self.selectedIndex = 0
    }
    
    private func setupTabs() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let searchModalTableViewController = UINavigationController(rootViewController: CapsuleMapViewController())
        let locationConfirmationViewController = UINavigationController(rootViewController: LocationMapkitViewController())
        let notificationViewController = UINavigationController(rootViewController: FriendsRequestViewController())
        let profileViewController = UINavigationController(rootViewController: UserProfileViewController())
        
        homeViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Home_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Home_Select", targetSize: CGSize(width: 24, height: 24)))
        searchModalTableViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Search_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Search_Select", targetSize: CGSize(width: 24, height: 24)))
        locationConfirmationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Write_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Write_Select", targetSize: CGSize(width: 24, height: 24)))
        locationConfirmationViewController.tabBarItem.tag = 2
        notificationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Activity_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Activity_Select", targetSize: CGSize(width: 24, height: 24)))
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Profile_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Profile_Select", targetSize: CGSize(width: 24, height: 24)))
        let viewControllers = [homeViewController, searchModalTableViewController, locationConfirmationViewController, notificationViewController, profileViewController]
        self.viewControllers = viewControllers
        self.tabBar.tintColor = UIColor(hex: "#C82D6B")
        self.tabBar.backgroundColor = .white
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 2 {
            let locationConfirmationVC = LocationMapkitViewController()
            locationConfirmationVC.modalPresentationStyle = .pageSheet
            tabBarController.present(locationConfirmationVC, animated: true, completion: nil)
            return false
        }
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

