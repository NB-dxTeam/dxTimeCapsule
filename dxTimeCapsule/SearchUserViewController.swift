import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage

class SearchUserViewController: UIViewController {
    let searchButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupButton()
        print("View did load")

    }
    
    private func setupUI() {
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    private func setupButton() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.backgroundColor = .systemBlue
        searchButton.setTitle("친구 찾기", for: .normal)
        searchButton.layer.cornerRadius = 10
        searchButton.setTitleColor(.white, for: .normal)

    }
    
    @objc func searchButtonTapped() {
        let searchModalVC = SearchModalViewController()
        searchModalVC.modalPresentationStyle = .fullScreen
        present(searchModalVC, animated: true, completion: nil)
    }
}
