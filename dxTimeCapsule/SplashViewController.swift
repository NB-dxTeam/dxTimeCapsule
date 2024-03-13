import UIKit
import SnapKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let closedBoxImageView = UIImageView(image: UIImage(named: "Splash_Entropy"))
        closedBoxImageView.contentMode = .scaleAspectFit
        
        view.addSubview(closedBoxImageView)
        
        // SnapKit을 사용하여 이미지 뷰 위치와 크기 설정
        closedBoxImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
        }
        
        // 이미지 뷰를 투명한 상태로 초기화
        closedBoxImageView.alpha = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 이미지 뷰가 서서히 나타나고
            UIView.animate(withDuration: 1.0, animations: {
                closedBoxImageView.alpha = 1.0 // 이미지 뷰를 서서히 나타나도록 투명도를 1로 변경
            }) { _ in
                UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseInOut, animations: {
                    closedBoxImageView.alpha = 0.0 // 이미지 뷰를 서서히 투명하게 만들어 사라지도록 투명도를 0으로 변경
                }) { _ in
                    // 로그인 뷰 컨트롤러 대신 메인 탭바를 표시하도록 변경
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                    

                    let mainTabBarController = LoginViewController()
                    let navigationController = mainTabBarController
                    sceneDelegate.window?.rootViewController = navigationController
                }
            }
        }
    }
}
