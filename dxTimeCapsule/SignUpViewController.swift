import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpViewController: UIViewController  {
    // MARK: - UI Components
    var profileImageUrl: String?
    
    
    private let profileImageView = UIImageView()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let userNameTextField = UITextField()
    private let signUpButton = UIButton(type: .system)
    
    // 중복확인 버튼
    private let checkEmailButton = UIButton(type: .system)
    private let checkUserNameButton = UIButton(type: .system)
    
    // 유효성 라벨
    private let emailValidationLabel = UILabel()
    private let passwordValidationLabel = UILabel()
    private let confirmPasswordValidationLabel = UILabel()
    private let userNameValidationLabel = UILabel()

    
    private let labelsContainerView = UIView()
        
    private let dividerView = UIView()
    
    private let alreadyHaveAccountLabel = UILabel()
    private let signInActionLabel = UILabel()
    
    
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signUpButton.setInstagram()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .white
        
        // Configure the profileImageView
        profileImageView.image = UIImage(named: "cameraIcon")
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true // if you want the image to be tappable
        profileImageView.setRoundedImage()
        view.addSubview(profileImageView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Configure the text fields
        configureTextField(emailTextField, placeholder: "Enter your email")
        configureTextField(passwordTextField, placeholder: "Enter your password", isSecure: true)
        configureTextField(confirmPasswordTextField, placeholder: "Confirm your password", isSecure: true)
        configureTextField(userNameTextField, placeholder: "Enter your userName")
        
        // configure the validationLabel
        configureValidationLabel(emailValidationLabel)
        configureValidationLabel(passwordValidationLabel)
        configureValidationLabel(confirmPasswordValidationLabel)
        configureValidationLabel(userNameValidationLabel)
        view.addSubview(emailValidationLabel)
        view.addSubview(passwordValidationLabel)
        view.addSubview(confirmPasswordValidationLabel)
        view.addSubview(userNameValidationLabel)
        
        // Configure the checkEmailButton
        configureLineButton(checkEmailButton, title: "Check Email")
        checkEmailButton.addTarget(self, action: #selector(checkEmailPressed), for: .touchUpInside)
        
        // Configure the checkUserNameButton
        configureLineButton(checkUserNameButton, title: "Check UserName")
        checkUserNameButton.addTarget(self, action: #selector(checkUserNamePressed), for: .touchUpInside)
        
        view.addSubview(checkEmailButton)
        view.addSubview(checkUserNameButton)
        
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
        signInActionLabel.textColor = UIColor(hex: "#C82D6B")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(alreadyHaveAccountTapped))
        signInActionLabel.addGestureRecognizer(tapGesture)
    }
    
    private func setupLayouts() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(180)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(44)
        }
        
        checkEmailButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.right.equalToSuperview().inset(10)
            make.width.equalTo(100)
        }

        emailValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(5)
            make.left.right.equalTo(emailTextField)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailValidationLabel.snp.bottom).offset(10)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        
        passwordValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.left.right.equalTo(passwordTextField)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordValidationLabel.snp.bottom).offset(10)
            make.left.right.equalTo(passwordTextField)
            make.height.equalTo(44)
        }
        
        confirmPasswordValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(5)
            make.left.right.equalTo(confirmPasswordTextField)
        }
        
        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordValidationLabel.snp.bottom).offset(10)
            make.left.right.equalTo(passwordTextField)
            make.height.equalTo(44)
        }
        
        checkUserNameButton.snp.makeConstraints { make in
            make.centerY.equalTo(userNameTextField)
            make.right.equalToSuperview().inset(10)
            make.width.equalTo(120)
        }
        
        userNameValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(5)
            make.left.right.equalTo(userNameTextField)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(20)
            make.left.right.equalTo(userNameTextField)
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
    
    private func configureLineButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(hex: "#FF3A4A"), for: .normal) // 글씨 색상 설정
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 14) // 텍스트 크기 및 폰트 설정
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1 // 테두리 두께 설정
        button.layer.borderColor = UIColor(hex: "#FF3A4A").cgColor // 테두리 색상 설정
        
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
    
    // MARK: - Button Actions
    
    @objc private func checkEmailPressed() {
        guard let email = emailTextField.text, !email.isEmpty else {
            presentAlert(title: "Error", message: "사용할 메일주소를 입력해 주세요.")
            return
        }
        
        Firestore.firestore().collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.presentAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                self.emailValidationLabel.text = "사용 중인 메일주소입니다."
                self.emailValidationLabel.textColor = .red
            } else {
                self.emailValidationLabel.text = "이메일 확인이 완료 되었습니다."
                self.emailValidationLabel.textColor = .gray
            }
        }
    }

    @objc private func checkUserNamePressed() {
        guard let userName = userNameTextField.text, !userName.isEmpty else {
            presentAlert(title: "Error", message: "사용할 닉네임을 입력해 주세요.")
            return
        }
        
        Firestore.firestore().collection("users").whereField("userName", isEqualTo: userName).getDocuments { snapshot, error in
            if let error = error {
                self.presentAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                self.userNameValidationLabel.text = "사용 중인 닉네임입니다."
                self.userNameValidationLabel.textColor = .red
            } else {
                self.userNameValidationLabel.text = "닉네임 확인이 완료 되었습니다."
                self.userNameValidationLabel.textColor = .gray
            }
        }
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
    @objc func emailTextFieldDidChange(_ textField: UITextField) {
        if let email = textField.text, isValidEmail(email) {
            emailValidationLabel.text = ""
        } else {
            emailValidationLabel.text = "유효한 이메일 주소를 입력하세요."
        }
    }

    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        if let password = textField.text, isPasswordStrong(password) {
            passwordValidationLabel.text = ""
        } else {
            passwordValidationLabel.text = "비밀번호는 8자 이상 입력해주세요."
        }
    }
    
    @objc func confirmPasswordTextFieldDidChange(_ textField: UITextField) {
        guard let confirmPassword = textField.text, let password = passwordTextField.text else {
            confirmPasswordValidationLabel.text = "비밀번호를 다시 입력해주세요."
            return
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordValidationLabel.text = "" // 입력이 없을 때는 메시지를 표시하지 않음
        } else if confirmPassword == password {
            confirmPasswordValidationLabel.text = "" // 비밀번호가 일치할 때
        } else {
            confirmPasswordValidationLabel.text = "입력된 비밀번호와 다릅니다." // 비밀번호가 일치하지 않을 때
        }
    }
    
    // 회원가입 함수
    @objc private func signUpButtonPressed() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let userName = userNameTextField.text, !userName.isEmpty,
              let profileImage = profileImageView.image,
              emailValidationLabel.text == "이메일 확인이 완료 되었습니다.",
              userNameValidationLabel.text == "닉네임 확인이 완료 되었습니다." else {
            presentAlert(title: "입력 오류", message: "모든 필드를 채워주세요.")
            return
        }
        
        let termsVC = TermsViewController()
        
        termsVC.email = email
        termsVC.password = password
        termsVC.userName = userName
        termsVC.profileImage = profileImage
        
        termsVC.modalPresentationStyle = .formSheet // iPad에서 반 모달 스타일로 표시합니다.
        termsVC.modalTransitionStyle = .coverVertical // 모달창이 아래에서 올라오는 효과
        
        termsVC.delegate = self

        // iOS 15 이상에서는 반 모달 스타일을 지정할 수 있습니다.
        if #available(iOS 15.0, *) {
            if let sheet = termsVC.sheetPresentationController {
                sheet.detents = [.medium()] // .medium() 또는 .large()로 설정할 수 있습니다.
            }
        }
        
        self.present(termsVC, animated: true, completion: nil)
        
        
        /*
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
                        "userName": userName,
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
        */
    }
    


}

// MARK: - TermsViewControllerDelegate
extension SignUpViewController: TermsViewControllerDelegate {
    func didCompleteSignUp() {
        dismiss(animated: true) {
            // 회원가입 성공 후 메인 화면으로 이동
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                let mainTabBarController = MainTabBarView()
                sceneDelegate.window?.rootViewController = mainTabBarController
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

// MARK: - Private Function

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func isPasswordStrong(_ password: String) -> Bool {
    let minLength = 8
    
    // For Strong Passward
//    let hasUpperCase = password.range(of: "[A-Z]", options: .regularExpression) != nil
//    let hasLowerCase = password.range(of: "[a-z]", options: .regularExpression) != nil
//    let hasDigits = password.range(of: "\\d", options: .regularExpression) != nil
//    let hasSpecialCharacters = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
    
    return password.count >= minLength// && hasUpperCase && hasLowerCase && hasDigits && hasSpecialCharacters
}

private func configureValidationLabel(_ label: UILabel) {
    label.text = "" // 초기 메시지는 비어 있음
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .red // 유효성 검사 실패 메시지는 빨간색으로 표시
}


