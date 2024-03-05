import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSheetPresentation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showAlert()
    }
    
    
    // MARK: - UI Configuration
    private func setupSheetPresentation() {
        if let sheetController = self.presentationController as? UISheetPresentationController {
            sheetController.detents = [.small,.medium(), .large()]
            sheetController.prefersEdgeAttachedInCompactHeight = true
            sheetController.largestUndimmedDetentIdentifier = .medium
        }
    }
    
    // MARK: - Functions
    private func showAlert() {
        let alert = UIAlertController(title: "알림", message: "타임캡슐 생성 위치를 확인해주세요!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    // 여기에 사용자 인터랙션을 처리하기 위한 액션을 추가할 수 있습니다.
    

    // MARK: - Deinitialization
    deinit {
        // 여기에 정리 코드를 추가할 수 있습니다.
    }
}

// MARK: - SwiftUI Preview
import SwiftUI

struct MainTabBarViewPreview1 : PreviewProvider {
    static var previews: some View {
        MainTabBarView().toPreview()
    }
}

extension UISheetPresentationController.Detent {
    static var small: UISheetPresentationController.Detent {
        Self.custom { context in
            return context.maximumDetentValue * 0.25
        }
    }
}
