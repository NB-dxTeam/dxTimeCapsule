import UIKit
import SnapKit

class MainCreateCapsuleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    private let uploadAreaView = UIView()
    private let imageView = UIImageView()
    private let instructionLabel = UILabel()
    private let startUploadButton = UIButton()
    private let testPageButton = UIButton()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground // 시스템 배경색 사용
        setupUploadAreaView()
        setupInstructionLabel()
        setupStartUploadButton()
        setupTestPageButton()
    }
    
    // MARK: - Functions
    
    // 업로드 영역 뷰 설정
    private func setupUploadAreaView() {
        uploadAreaView.backgroundColor = .systemGray6 // 더 밝은 회색으로 설정
        uploadAreaView.layer.cornerRadius = 16 // 더 큰 둥근 모서리
        view.addSubview(uploadAreaView)
        
        uploadAreaView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // SnapKit을 사용한 레이아웃 제약 조건 설정
        uploadAreaView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20) // 상단 여백 감소
            make.width.height.equalTo(view.frame.width * 0.8) // 뷰 너비의 80% 크기로 조정
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // 안내 레이블 설정
    private func setupInstructionLabel() {
        instructionLabel.text = "타임캡슐에 담을 사진을 선택해주세요!"
        instructionLabel.font = .systemFont(ofSize: 18, weight: .medium) // 폰트 사이즈와 두께 조정
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        view.addSubview(instructionLabel)
        
        instructionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(uploadAreaView.snp.bottom).offset(30) // 여백 감소
            make.leading.trailing.equalTo(view).inset(20) // 좌우 여백 설정
        }
    }
    
    // 업로드 시작 버튼 설정
    private func setupStartUploadButton() {
        startUploadButton.setTitle("사진 선택", for: .normal)
        startUploadButton.setTitleColor(.white, for: .normal)
        startUploadButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium) // 폰트 사이즈와 두께 조정
        startUploadButton.backgroundColor = .systemBlue
        startUploadButton.layer.cornerRadius = 15 // 모서리 둥글기 조정
        startUploadButton.addTarget(self, action: #selector(startUploadButtonTapped), for: .touchUpInside)
        view.addSubview(startUploadButton)
        
        startUploadButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(instructionLabel.snp.bottom).offset(30) // 여백 감소
            make.width.equalTo(200) // 버튼 너비 증가
            make.height.equalTo(44) // 버튼 높이 표준화
        }
    }
    
    // 친구 검색 버튼 설정
    private func setupTestPageButton(){
        startUploadButton.addTarget(self, action: #selector(SearchPageButtonTapped), for: .touchUpInside)
        view.addSubview(testPageButton)
        
        testPageButton.snp.makeConstraints { make in
            make .centerX.equalToSuperview()
            make .top.equalTo(startUploadButton.snp.bottom).offset(60)
            make .width.equalTo(200)
            make.height.equalTo(44) // 버튼 높이 표준화
        }
    }
    
    // UIImagePickerController를 표시하는 메소드
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
    
    }
    
    
    // imagePickerController를 표시하는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let pickedImage = info[.originalImage] as? UIImage {
                    self.imageView.image = pickedImage
                    // 사용자 정의 Alert 또는 모달 뷰를 표시하여 이미지 확인
                    self.confirmImageSelection(with: pickedImage)
                }
            }
        }
    }
    
    // 이미지 선택 또는 모달 뷰를 표시하는 메소드
    private func confirmImageSelection(with image: UIImage) {
        // Action Sheet 생성
        let actionSheet = UIAlertController(title: "선택한 사진으로 진행하시겠습니까?", message: "", preferredStyle: .actionSheet)
        
        // "이 사진으로 선택하기" 액션
        let confirmAction = UIAlertAction(title: "이 사진으로 선택하기", style: .default) { [weak self] _ in
            let optionVC = UploadDetailViewController()
            self?.navigationController?.pushViewController(optionVC, animated: true)
        }
        
        // "다시 선택하기" 액션
        let cancelAction = UIAlertAction(title: "다시 선택하기", style: .cancel) { [weak self] _ in
            self?.imageView.image = image
            // 이미지 확정 후 UploadDetailViewController로 넘어가는 로직
            self?.startUploadButtonTapped() // 다시 이미지 선택 로직 호출
        }
        actionSheet.addAction(confirmAction)
        actionSheet.addAction(cancelAction)
        
        // iPad에서 Action Sheet를 사용할 경우, popoverPresentationController를 설정해야 합니다.
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @objc private func SearchPageButtonTapped() {
        let vc = SearchUserViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
        
    @objc private func startUploadButtonTapped() {
        // 액션 시트 생성
        let actionSheet = UIAlertController(title: "선택", message: "사진을 촬영하거나 앨범에서 선택해주세요.", preferredStyle: .actionSheet)
        
        // 카메라 액션 추가
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "카메라 촬영", style: .default, handler: { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            }))
        }
        
        // 사진 앨범 액션 추가
        actionSheet.addAction(UIAlertAction(title: "앨범에서 선택", style: .default, handler: { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }))
        
        // 취소 액션 추가
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // 액션 시트 표시
        present(actionSheet, animated: true)
    }
}
