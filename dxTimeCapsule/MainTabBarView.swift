import UIKit

class MainTabBarView: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabs()
        tabBar.barTintColor = UIColor.white
        self.delegate = self
    }
    
    // MARK: - Func
    private func setupTabs() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        homeViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Home_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Home_Select", targetSize: CGSize(width: 24, height: 24)))

        let searchModalTableViewController = UINavigationController(rootViewController: SearchModalTableViewController())
        searchModalTableViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Search_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Search_Select", targetSize: CGSize(width: 24, height: 24)))

        let locationConfirmationViewController = UINavigationController(rootViewController: LocationConfirmationViewController())
        locationConfirmationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Write_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Write_Select", targetSize: CGSize(width: 24, height: 24)))

        let notificationViewController = UINavigationController(rootViewController: NotificationViewController())
        notificationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Activity_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Activity_Select", targetSize: CGSize(width: 24, height: 24)))

        let profileViewController = UINavigationController(rootViewController: UserProfileViewController())
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Profile_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Profile_Select", targetSize: CGSize(width: 24, height: 24)))

        let viewControllers = [homeViewController, searchModalTableViewController, locationConfirmationViewController, notificationViewController, profileViewController]
        
        self.viewControllers = viewControllers
        self.tabBar.tintColor = UIColor(hex: "#D53369")
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == viewControllers?[2] {
            let locationConfirmationVC = LocationConfirmationViewController()
            locationConfirmationVC.modalPresentationStyle = .pageSheet // 또는 .formSheet
            locationConfirmationVC.isModalInPresentation = false // 모달 외부 탭하거나 아래로 당겨서 닫기 활성화
            self.present(locationConfirmationVC, animated: true, completion: nil)
            return false
        }
        return true
    }


    func resizeImage(imageName: String, targetSize: CGSize) -> UIImage? {
        guard let image = UIImage(named: imageName) else { return nil }
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
