import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
//    private let viewModel: BottomSheetControllerViewModel
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
        // 여기에 초기화 코드 추가
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 기본 설정을 여기에 추가
        // 예: 버튼, 레이블 등의 UI 요소 추가
    }
    
    // MARK: - UI Configuration
    // 여기에 UI 구성을 위한 메서드를 추가할 수 있습니다.
    
    // MARK: - Actions
    // 여기에 사용자 인터랙션을 처리하기 위한 액션을 추가할 수 있습니다.
    
    // MARK: - Additional Helpers
    // 여기에 추가적인 도우미 메서드를 작성할 수 있습니다.
    
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
