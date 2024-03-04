import UIKit
import SnapKit

class SearchUserViewController: UIViewController, UIViewControllerTransitioningDelegate {
    let searchButton = UIButton(type: .system)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupButton()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Button Setup
    private func setupButton() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.backgroundColor = .systemBlue
        searchButton.setTitle("친구 찾기", for: .normal)
        searchButton.layer.cornerRadius = 10
        searchButton.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - Action
    @objc func searchButtonTapped() {
        let searchModalVC = SearchModalTableViewController()
        searchModalVC.modalPresentationStyle = .fullScreen
        //        searchModalVC.transitioningDelegate = self // 커스텀 트랜지션 딜리게이트 설정
        present(searchModalVC, animated: true, completion: nil)
    }
    
    
}
