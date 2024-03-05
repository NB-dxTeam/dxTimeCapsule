import UIKit

class MainTabBarView: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabs()
        tabBar.barTintColor = UIColor.white
    }
    
    // MARK: - Func
    private func setupTabs() {
        let homeTabViewController = HomeViewController()
        homeTabViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Home_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Home_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let searchModalTableViewController = SearchUserTableViewController() // 이 부분에서 SearchViewController는 실제로 존재하는 UIViewController 클래스여야 합니다.
        searchModalTableViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Search_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Search_Select", targetSize: CGSize(width: 24, height: 24)))

        
        let createCapsuleViewController = MainCreateCapsuleViewController()
        createCapsuleViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Write_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Write_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let notificationViewController = FriendRequestsViewController()
        notificationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Activity_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Activity_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let profileViewController = UserProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Profile_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Profile_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let viewControllers = [homeTabViewController, searchModalTableViewController, createCapsuleViewController, notificationViewController, profileViewController]
        
        self.viewControllers = viewControllers.map { UINavigationController(rootViewController: $0 ) }
        self.tabBar.tintColor = UIColor(hex: "#D28488")
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
