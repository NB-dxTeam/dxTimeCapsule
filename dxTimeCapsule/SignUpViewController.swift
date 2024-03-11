import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpViewController: UIViewController  {
    // MARK: - UI Components
    var profileImageUrl: String?
    
    
    private let profileImageView = UIImageView()
    private let selectImageButton = UIButton()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let usernameTextField = UITextField()
    private let signUpButton = UIButton(type: .system)
    
    private let labelsContainerView = UIView()
        
    private let dividerView = UIView()
    
    private let alreadyHaveAccountLabel = UILabel()
    private let signInActionLabel = UILabel()
    
    
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        print("SignUpViewController - viewDidLoad() called")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signUpButton.setInstagram()
        selectImageButton.setInstagram()
        
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .white
        
        // Configure the profileImageView
        profileImageView.image = UIImage(named: "defaultProfileImage")
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true // if you want the image to be tappable
        profileImageView.setRoundedImage()
        view.addSubview(profileImageView)
        
        // Configure the selectImageButton
        configureButton(selectImageButton, title: "Select Image")
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        // Configure the text fields
        configureTextField(emailTextField, placeholder: "Enter your email")
        configureTextField(passwordTextField, placeholder: "Enter your password", isSecure: true)
        configureTextField(usernameTextField, placeholder: "Enter your username")
        
        // Configure the signUpButton
        configureButton(signUpButton, title: "Sign Up")
        signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
        
        // 디바이더 뷰 셋업
        dividerView.backgroundColor = .lightGray
        view.addSubview(dividerView)
        
        view.addSubview(labelsContainerView)
        
        // labelsContainerView 내에 라벨들을 추가
        labelsContainerView.addSubview(alreadyHaveAccountLabel)
        labelsContainerView.addSubview(signInActionLabel)
        
        // Configure the Label
        alreadyHaveAccountLabel.text = "Already have an account?"
        alreadyHaveAccountLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
        alreadyHaveAccountLabel.textAlignment = .center
        alreadyHaveAccountLabel.isUserInteractionEnabled = true
        
        signInActionLabel.text = "Sign in !"
        signInActionLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
        signInActionLabel.textAlignment = .center
        signInActionLabel.isUserInteractionEnabled = true
        signInActionLabel.textColor = UIColor(hex: "#FF3A4A")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(alreadyHaveAccountTapped))
        signInActionLabel.addGestureRecognizer(tapGesture)
    }
    
    private func setupLayouts() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(220)
        }
        
        selectImageButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(selectImageButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.left.right.equalTo(passwordTextField)
            make.height.equalTo(44)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.left.right.equalTo(usernameTextField)
            make.height.equalTo(50)
        }
        
        // Ensure dividerView is added to the view before setting constraints
        dividerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-70)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        // labelsContainerView에 대한 높이 제약 조건 추가
        labelsContainerView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            // 높이를 명시적으로 설정
            make.height.equalTo(20)
        }
        
        alreadyHaveAccountLabel.snp.makeConstraints { make in
            make.left.equalTo(labelsContainerView.snp.left)
            make.centerY.equalTo(labelsContainerView.snp.centerY)
            make.height.equalTo(labelsContainerView.snp.height) // labelsContainerView와 동일한 높이를 가지도록 설정
        }
        
        signInActionLabel.snp.makeConstraints { make in
            make.right.equalTo(labelsContainerView.snp.right)
            make.centerY.equalTo(labelsContainerView.snp.centerY)
            make.left.equalTo(alreadyHaveAccountLabel.snp.right).offset(5)
            make.height.equalTo(labelsContainerView.snp.height) // labelsContainerView와 동일한 높이를 가지도록 설정
        }
    }
    
    // MARK: - Functions
    private func configureTextField(_ textField: UITextField, placeholder: String, isSecure: Bool = false) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = isSecure
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.layer.backgroundColor = UIColor.systemGray6.cgColor
        textField.font = UIFont.pretendardRegular(ofSize: 14)

        view.addSubview(textField)
    }
    
    private func configureButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 14) // 텍스트 크기 및 폰트 설정
        button.layer.cornerRadius = 10
        
        button.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        view.addSubview(button)
    }
    
    private func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    // MARK: - Actions
    
    @objc private func selectImagePressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true // if you want to allow editing
        imagePickerController.sourceType = .photoLibrary // or .camera if you want to take a photo
        present(imagePickerController, animated: true)
    }
    
    @objc private func selectImage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default) { _ in
            self.openCamera()
        }
        
        let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.openLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    private func openLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    
    // 이전 화면으로 돌아가기
    @objc private func dismissSelf() {
        // 네비게이션 컨트롤러를 사용하는 경우 이전 화면으로 돌아감
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            // 네비게이션 컨트롤러가 없는 경우, 모달을 닫음
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func alreadyHaveAccountTapped() {
        let loginViewController = LoginViewController()
        self.present(loginViewController, animated: true, completion: nil)
        
    }
    
    // 회원가입 함수
    @objc private func signUpButtonPressed() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let profileImage = profileImageView.image else {
            presentAlert(title: "입력 오류", message: "모든 필드를 채워주세요.")
            return
        }
        
        // Firebase Authentication을 사용하여 사용자를 생성합니다.
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(title: "회원가입 실패", message: error.localizedDescription)
                return
            }
            guard let uid = authResult?.user.uid else { return }
            
            // Firebase Storage에 프로필 이미지 업로드 로직을 여기에 추가합니다.
            let fileName = "profileImage_\(uid)_\(Int(Date().timeIntervalSince1970)).jpg"
            let storageRef = Storage.storage().reference().child("userProfileImages/\(uid)/\(fileName)")
            guard let imageData = profileImage.jpegData(compressionQuality: 0.75) else { return }
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.presentAlert(title: "이미지 업로드 실패", message: error.localizedDescription)
                    return
                }
                storageRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        self.presentAlert(title: "이미지 URL 가져오기 실패", message: error?.localizedDescription ?? "알 수 없는 오류")
                        return
                    }
                    // Firestore에 사용자 정보와 프로필 이미지 URL 저장
                    let userData: [String: Any] = [
                        "uid": uid,
                        "email": email,
                        "username": username,
                        "profileImageUrl": downloadURL.absoluteString,
                        "friends": [],
                        "friendRequestsSent": [],
                        "friendRequestsReceived": []
                    ]
                    Firestore.firestore().collection("users").document(uid).setData(userData) { error in
                        if let error = error {
                            self.presentAlert(title: "정보 저장 실패", message: error.localizedDescription)
                        } else {
                            // 회원가입 성공 시 알림 창 표시 및 홈 화면으로 이동
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "회원가입 성공", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                                    // 홈 화면으로 이동
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let sceneDelegate = windowScene.delegate as? SceneDelegate {
                                        sceneDelegate.window?.rootViewController = MainTabBarView()
                                    }
                                })
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Image Picker Delegate
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        // 선택된 이미지를 임시로 저장합니다. profileImageView는 UIImageView 타입의 아웃렛 변수입니다.
        profileImageView.image = image
        
//         이미지를 둥글게 처리합니다.
        if let roundedImage = image.roundedImage() {
            profileImageView.image = roundedImage
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

