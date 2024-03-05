import UIKit

class MainTabBarView: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Properties
    
    private var locationConfirmationVC: LocationMapkitViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabs()
        tabBar.barTintColor = .white
        self.delegate = self
    }
    
    // MARK: - Func
    
    private func setupTabs() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        homeViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Home_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Home_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let searchModalTableViewController = UINavigationController(rootViewController: SearchModalTableViewController())
        searchModalTableViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Search_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Search_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let locationConfirmationViewController = UINavigationController(rootViewController: LocationMapkitViewController(viewModel: .init()))
        locationConfirmationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Write_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Write_Select", targetSize: CGSize(width: 24, height: 24)))
        locationConfirmationViewController.tabBarItem.tag = 2 // 세 번째 탭을 나타내는 태그를 설정
        
        let notificationViewController = UINavigationController(rootViewController: NotificationViewController())
        notificationViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Activity_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Activity_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let profileViewController = UINavigationController(rootViewController: UserProfileViewController())
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: resizeImage(imageName: "Light=Profile_Deselect", targetSize: CGSize(width: 24, height: 24)), selectedImage: resizeImage(imageName: "Light=Profile_Select", targetSize: CGSize(width: 24, height: 24)))
        
        let viewControllers = [homeViewController, searchModalTableViewController, locationConfirmationViewController, notificationViewController, profileViewController]
        
        self.viewControllers = viewControllers
        self.tabBar.tintColor = UIColor(hex: "#D53369")
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.tabBarItem.tag == 2 { // 세 번째 탭이 선택된 경우
            let locationConfirmationVC = LocationMapkitViewController(viewModel: .init())
            locationConfirmationVC.modalPresentationStyle = .pageSheet // 모달 시트 페이지로 표시
            self.present(locationConfirmationVC, animated: true, completion: nil) // 모달을 현재 뷰 컨트롤러에서 표시
        }
    }
    
    // 이미지 리사이즈 함수
    func resizeImage(imageName: String, targetSize: CGSize) -> UIImage? {
        guard let image = UIImage(named: imageName) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resizedImage
    }
}


// MARK: - Preview
import SwiftUI
struct TabBarPreView : PreviewProvider {
    static var previews: some View {
        MainTabBarView().toPreview()
    }
}
