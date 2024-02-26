import UIKit
import SnapKit
import MapKit

class UploadDetailViewController: UIViewController {
    
    // UI 컴포넌트 선언
    private let selectedImageView = UIImageView()
    private let commentTextField = UITextField()
    private let tagSectionView = UIView()
    private let musicSectionView = UIView()
    private let notificationSectionView = UIView()
    private let locationSectionView = MKMapView()
    private let saveButton = UIButton()
    
    // 뷰의 생명주기: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // UI 설정
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupSelectedImageView()
        setupCommentTextField()
        setupTagSectionView()
        setupMusicSectionView()
        setupNotificationSectionView()
        setupLocationSectionView()
        setupSaveButton()
    }
    
    // 선택된 이미지 뷰 설정
    private func setupSelectedImageView() {
        selectedImageView.contentMode = .scaleAspectFit
        view.addSubview(selectedImageView)
        
        selectedImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(selectedImageView.snp.width)
        }
    }
    
    // 코멘트 입력 필드 설정
    private func setupCommentTextField() {
        commentTextField.placeholder = "코멘트를 입력하세요"
        commentTextField.borderStyle = .roundedRect
        view.addSubview(commentTextField)
        
        commentTextField.snp.makeConstraints { make in
            make.top.equalTo(selectedImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    // 태그 섹션 뷰 설정
    private func setupTagSectionView() {
        // 태그 섹션 구성 (디자인과 세부 구현은 생략)
    }
    
    // 음악 섹션 뷰 설정
    private func setupMusicSectionView() {
        // 음악 섹션 구성 (디자인과 세부 구현은 생략)
    }
    
    // 알림 섹션 뷰 설정
    private func setupNotificationSectionView() {
        // 알림 섹션 구성 (디자인과 세부 구현은 생략)
    }
    
    // 위치 섹션 뷰 설정
    private func setupLocationSectionView() {
        // 위치 섹션 구성 (디자인과 세부 구현은 생략)
    }
    
    // 저장 버튼 설정
    private func setupSaveButton() {
        saveButton.setTitle("저장", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 10
        view.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        // 사진 세부사항 저장 로직
    }
}
