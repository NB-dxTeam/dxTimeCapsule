//
//  UserProfileViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0051 on 2/28/24.
//

import UIKit
import SnapKit
import SDWebImage
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    private let userProfileViewModel = UserProfileViewModel()
    
    // MARK: - UI Components
    private let labelsContainerView = UIView()
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let editUsernameButton = UIButton()
    private let emailLabel = UILabel()
//    private let selectImageLabel = UILabel()
    private let logoutButton = UIButton()
    private let areYouSerious = UILabel()
    private let deleteAccountLabel = UILabel()
    private let dividerView = UIView()
    private var loadingIndicator = UIActivityIndicatorView(style: .medium) // 로딩 인디케이터 추가\
    private let friendListButton = UIButton()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        showLoadingIndicator() // 데이터 로딩 전 로딩 인디케이터 표시
        userProfileViewModel.fetchUserData { [weak self] in
            self?.hideLoadingIndicator() // 데이터 로딩 완료 후 로딩 인디케이터 숨김
            self?.bindViewModel()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 이미지 뷰의 크기에 따라 cornerRadius를 동적으로 설정합니다.
        let imageSize: CGFloat = profileImageView.frame.width
        profileImageView.layer.cornerRadius = imageSize / 2
//        logoutButton.backgroundColor = UIColor(hex: "#FF3A4A")
        logoutButton.setInstagram()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(editUsernameButton)
        view.addSubview(logoutButton)
        view.addSubview(dividerView)
        view.addSubview(emailLabel)
        view.addSubview(labelsContainerView)
        view.addSubview(loadingIndicator)
        view.addSubview(friendListButton)
        
        
        // 로딩 인디케이터 설정
        loadingIndicator.center = view.center
        
        // Profile Image View Setup
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        
        // 프로필 이미지 뷰 설정
        profileImageView.isUserInteractionEnabled = true
        
        // 프로필 이미지 탭 제스처 추가
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        profileImageView.addGestureRecognizer(imageTapGesture)
        
        let imageSize: CGFloat = 220 // 원하는 이미지 크기로 설정
        profileImageView.layer.cornerRadius = imageSize / 2 // 이미지 뷰를 둥글게 처리하기 위해 반지름을 이미지 크기의 절반으로 설정
        
        // "Edit" 레이블 추가
        let editLabel = UILabel()
        editLabel.text = "Edit"
        editLabel.font = UIFont.pretendardBold(ofSize: 15)
        editLabel.textColor =  .white
        
        profileImageView.addSubview(editLabel)
        
        editLabel.snp.makeConstraints { make in
          make.bottom.equalTo(profileImageView.snp.bottom).offset(-10)
          make.centerX.equalTo(profileImageView.snp.centerX)
        }
        
        // Nickname Label Setup
        nicknameLabel.font = .pretendardSemiBold(ofSize: 24)
        nicknameLabel.textAlignment = .center
        
        // Edit Nickname Button Setup
        editUsernameButton.setTitle("Edit", for: .normal)
        editUsernameButton.titleLabel?.font = .pretendardSemiBold(ofSize: 15)
        editUsernameButton.setTitleColor(.darkGray, for: .normal)
        editUsernameButton.addTarget(self, action: #selector(editUsernameTapped), for: .touchUpInside)

        // Email Label Setup
        logoutButton.titleLabel?.font = .pretendardSemiBold(ofSize: 24)
        emailLabel.textAlignment = .center
        
        // Logout Button Setup
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.layer.cornerRadius = 16
//        logoutButton.backgroundColor = UIColor(hex: "#FF3A4A")
        logoutButton.setInstagram()
        logoutButton.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        
        // 그림자 설정
        logoutButton.layer.shadowColor = UIColor.black.cgColor
        logoutButton.layer.shadowRadius = 6 // 그림자의 블러 정도 설정 (조금 더 부드럽게)
        logoutButton.layer.shadowOpacity = 0.3 // 그림자의 투명도 설정 (적당한 농도로)
        logoutButton.layer.shadowOffset =  CGSize(width: 0, height: 3) // 그림자 방향 설정 (아래로 조금 더 멀리)
        
        
        logoutButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        // Search User Button Setup
        friendListButton.setTitle("친구 목록보기", for: .normal)
        friendListButton.titleLabel?.font = .pretendardSemiBold(ofSize: 14)
        friendListButton.setTitleColor(.darkGray, for: .normal)
        friendListButton.addTarget(self, action: #selector(friendListButtonTapped), for: .touchUpInside)
        
        
        // Divider View Setup
        dividerView.backgroundColor = .lightGray
        
        // "정말 탈퇴하실건가요?" 라벨 설정
        areYouSerious.text = "Are you really going to leave?"
        areYouSerious.font = .pretendardSemiBold(ofSize: 14)
        areYouSerious.textColor = .black
        
        // Delete Account Label Setup
        deleteAccountLabel.text = "Leave Account"
        deleteAccountLabel.font = .pretendardSemiBold(ofSize: 14)
        deleteAccountLabel.textColor = UIColor(hex: "#C82D6B")
        deleteAccountLabel.textAlignment = .center
        
        labelsContainerView.addSubview(areYouSerious)
        labelsContainerView.addSubview(deleteAccountLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteProfileTapped))
        deleteAccountLabel.isUserInteractionEnabled = true // 사용자 인터랙션 활성화
        deleteAccountLabel.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        // Profile Image View Constraints
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-130)
            make.width.height.equalTo(150)
            profileImageView.setRoundedImage()
        }
        
        // Nickname Label Constraints
        nicknameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(20) // 수정된 부분
            make.left.right.equalToSuperview().inset(20)
        }

        editUsernameButton.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameLabel)
            make.leading.equalTo(nicknameLabel.snp.trailing).offset(-30)
            make.width.height.equalTo(20) // Adjust the size as needed
        }
        
        // Email Label Constraints
        emailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Logout Button Constraints
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
        
        friendListButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoutButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(20)
        }
        
        // Ensure dividerView is added to the view before setting constraints
        dividerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-70)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        // labelsContainerView에 대한 높이 제약 조건 추가
        labelsContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dividerView.snp.bottom).offset(15)
            // 높이를 명시적으로 설정
            make.height.equalTo(20)
        }
        
        // Delete Account Label Constraints
        areYouSerious.snp.makeConstraints { make in
            make.left.equalTo(labelsContainerView.snp.left)
            make.centerY.equalTo(labelsContainerView.snp.centerY)
        }
        
        deleteAccountLabel.snp.makeConstraints { make in
            make.right.equalTo(labelsContainerView.snp.right)
            make.centerY.equalTo(labelsContainerView.snp.centerY)
            make.left.equalTo(areYouSerious.snp.right).offset(5)
        }
        
        // 로딩 인디케이터 제약 조건 추가
         loadingIndicator.snp.makeConstraints { make in
             make.center.equalToSuperview()
         }
    }

    // MARK: - Loading Indicator
      private func showLoadingIndicator() {
          loadingIndicator.startAnimating()
          profileImageView.isHidden = true // 로딩 중에는 프로필 이미지 숨김
          nicknameLabel.isHidden = true // 로딩 중에는 닉네임 레이블 숨김
          emailLabel.isHidden = true // 로딩 중에는 이메일 레이블 숨김
      }
      
      private func hideLoadingIndicator() {
          loadingIndicator.stopAnimating()
          loadingIndicator.isHidden = true
          profileImageView.isHidden = false // 로딩 완료 후 프로필 이미지 표시
          nicknameLabel.isHidden = false // 로딩 완료 후 닉네임 레이블 표시
          emailLabel.isHidden = false // 로딩 완료 후 이메일 레이블 표시
      }
    
    // MARK: - Binding
    private func bindViewModel() {
        // 프로필 이미지 URL이 nil이거나 비어있는 경우 기본 이미지 사용
        if let profileImageUrl = userProfileViewModel.profileImageUrl, !profileImageUrl.isEmpty {
            profileImageView.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(named: "defaultProfileImage"))
        } else {
            // 기본 이미지를 사용하거나 이미지가 없는 경우를 처리할 수 있습니다.
            profileImageView.image = UIImage(named: "LoginLogo")
        }
        
        // 닉네임 설정
        nicknameLabel.text = userProfileViewModel.nickname
        
        // 이메일 설정
        emailLabel.text = userProfileViewModel.email
        
        // 프로필 이미지 설정
        if let profileImageUrl = userProfileViewModel.profileImageUrl, !profileImageUrl.isEmpty {
            profileImageView.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(named: "defaultProfileImage")) { [weak self] _, _, _, _ in
                // 이미지가 로드된 후에 실행되는 클로저
                self?.profileImageView.setNeedsLayout() // 이미지뷰를 레이아웃 갱신 요청
                self?.profileImageView.layoutIfNeeded() // 이미지뷰의 레이아웃 갱신
            }
        } else {
            // 기본 이미지를 사용하거나 이미지가 없는 경우를 처리할 수 있습니다.
            profileImageView.image = UIImage(named: "LoginLogo")
        }
    }

// MARK: - Fuctions
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true)
        }
    }

    func openPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func editUsernameTapped() {
        let alertController = UIAlertController(title: "닉네임 수정", message: "새로운 닉네임을 입력하세요.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "새로운 닉네임"
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            if let newNickname = alertController.textFields?.first?.text, !newNickname.isEmpty {
                self?.updateUsername(newNickname)
            } else {
                // Show an error message if the new username is empty
                self?.showErrorMessage("닉네임을 입력하세요.")
            }
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func updateUsername(_ newUsername: String) {
        // Update locally
        nicknameLabel.text = newUsername
        
        // Update on server (Firestore)
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.setData(["username": newUsername], merge: true) { error in
            if let error = error {
                print("Error updating username in Firestore: \(error.localizedDescription)")
                // If update fails, revert back the username locally
                self.nicknameLabel.text = self.userProfileViewModel.nickname
            } else {
                print("Username updated successfully")
            }
        }
    }


    private func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    
    @objc private func logoutTapped() {
        let alertController = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "예", style: .default) { [weak self] _ in
            self?.performLogout()
        }
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
            
            let loginViewController = LoginViewController()
            sceneDelegate.window?.rootViewController = loginViewController
            sceneDelegate.window?.makeKeyAndVisible()
            
            print("로그아웃 성공")
            
        } catch let signOutError as NSError {
            print("로그아웃 실패: \(signOutError.localizedDescription)")
        }
    }
    
    @objc private func searchUserButtonTapped() {
        // 새로운 ViewController를 생성합니다.
        let searchUserViewController = SearchUserTableViewController()
        
        // 현재 ViewController에서 모달로 새 ViewController를 표시합니다.
        self.present(searchUserViewController, animated: true, completion: nil)
    }
    
    @objc private func friendListButtonTapped() {
        let friendListViewController = FriendsListViewController()
        
        // 현재 ViewController에서 모달로 새 ViewController를 표시합니다.
        self.present(friendListViewController, animated: true, completion: nil)
    }
    
    
    @objc private func deleteProfileTapped() {
        let alertController = UIAlertController(title: "회원 탈퇴", message: "정말로 계정을 삭제하시겠습니까?\n 소중한 추억들이 영원히 사라집니다.", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func deleteAccount() {
        // 사용자 ID를 가져옵니다.
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Firestore에서 사용자 데이터 삭제
        let userDocument = Firestore.firestore().collection("users").document(userId)
        userDocument.delete { error in
            if let error = error {
                // Firestore에서 사용자 데이터 삭제 실패 처리
                print("Firestore에서 사용자 데이터 삭제 실패: \(error.localizedDescription)")
                return
            }
            
            // Firebase Storage에서 사용자 이미지 삭제
            let storageRef = Storage.storage().reference().child("userProfileImages/\(userId)")
            storageRef.delete { error in
                if let error = error as NSError? {
                    // Storage 오류 코드 확인
                    if error.domain == StorageErrorDomain && error.code == StorageErrorCode.objectNotFound.rawValue {
                        // 이미지가 존재하지 않는 경우, 오류를 무시하고 계속 진행
                        print("이미지가 존재하지 않으므로 삭제 과정을 건너뜁니다.")
                    } else {
                        // 다른 유형의 오류 처리
                        print("Storage에서 이미지 삭제 실패: \(error.localizedDescription)")
                    }
                    return
                }
                // 이미지 삭제 성공 처리
                print("이미지가 성공적으로 삭제되었습니다.")
            }
            
            // Firebase Authentication에서 사용자 삭제
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    // 사용자 삭제 실패 처리
                    print("사용자 삭제 실패: \(error.localizedDescription)")
                } else {
                    // 성공적으로 모든 작업 완료 후 처리
                    print("사용자 계정 및 데이터 삭제 완료")
                    DispatchQueue.main.async {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                        guard let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                        
                        let loginViewController = LoginViewController()
                        sceneDelegate.window?.rootViewController = loginViewController
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
    @objc private func changePhotoTapped() {
        let alertController = UIAlertController(title: "프로필 사진 변경", message: "사진을 선택해주세요.", preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "카메라로 촬영하기", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }

        let photoLibraryAction = UIAlertAction(title: "앨범에서 선택하기", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }
        alertController.addAction(photoLibraryAction)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }

    
    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        // Update profile image view
        profileImageView.image = image
        dismiss(animated: true)
        
        // Upload image to server (Firebase Storage) and update Firestore if needed
        uploadImageToServer(image)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // MARK: - Image Upload
    private func uploadImageToServer(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else {
            // User not authenticated
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            // Error converting image to data
            return
        }
        
        let storageRef = Storage.storage().reference().child("userProfileImages/\(uid)/profileImage.jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            // Image uploaded successfully
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error retrieving download URL: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Update user profile image URL in Firestore
                let userRef = Firestore.firestore().collection("users").document(uid)
                userRef.setData(["profileImageUrl": downloadURL.absoluteString], merge: true) { error in
                    if let error = error {
                        print("Error updating profile image URL in Firestore: \(error.localizedDescription)")
                        return
                    }
                    print("Profile image URL updated successfully")
                }
            }
        }
    }
    
}

func configureButton(_ button: UIButton, title: String) {
    button.setTitle(title, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.snp.makeConstraints { make in
        make.height.equalTo(44)
    }
}
