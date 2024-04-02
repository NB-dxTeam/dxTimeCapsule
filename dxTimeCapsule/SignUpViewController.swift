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
    private let signUpButton : UIButton = {
        let button = UIButton(type: .system)
        let title = "Sign Up" // 버튼의 제목 설정
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(hex: "#C82D6B"), for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        button.layer.borderWidth = 1.5 // 라인의 너비 설정
        button.layer.borderColor = UIColor(hex: "#C82D6B").cgColor
        return button
    }()
    
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
        keyBoardHide()
        
        // 키보드 알림 구독 설정
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldDidChange(_:)), for: .editingChanged)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        userNameTextField.delegate = self
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
////        signUpButton.setInstagram()
//    }
    
    override func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if userNameTextField.isFirstResponder {
            let bottomOfTextField = userNameTextField.convert(userNameTextField.bounds, to: self.view).maxY
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            let spacing: CGFloat = 20 // 원하는 텍스트 필드와 키보드 사이의 간격
            
            // 텍스트 필드와 키보드 사이의 간격을 계산합니다.
            let offset = bottomOfTextField - topOfKeyboard + spacing
            if offset > 0 {
                // 계산된 간격만큼 뷰를 올립니다.
                self.view.frame.origin.y = -offset
            }
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        // 키보드가 사라질 때 원래 위치로 뷰를 이동
        self.view.frame.origin.y = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        // "Edit" 레이블 추가
        let editLabel = UILabel()
        editLabel.text = "Edit"
        editLabel.font = UIFont.pretendardBold(ofSize: 15)
        editLabel.textColor =  .white
        editLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        view.addSubview(editLabel)
        
        editLabel.snp.makeConstraints { make in
          make.bottom.equalTo(profileImageView.snp.bottom).offset(-10)
          make.centerX.equalTo(profileImageView.snp.centerX)
        }
        
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
        configureLineButton(checkEmailButton, title: "check✓")
        checkEmailButton.addTarget(self, action: #selector(checkEmailPressed), for: .touchUpInside)
        
        // Configure the checkUserNameButton
        configureLineButton(checkUserNameButton, title: "check✓")
        checkUserNameButton.addTarget(self, action: #selector(checkUserNamePressed), for: .touchUpInside)
        
        view.addSubview(checkEmailButton)
        view.addSubview(checkUserNameButton)
        
        // Configure the signUpButton
        view.addSubview(signUpButton)
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
            let offset = UIScreen.main.bounds.height * (0.8/6.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(offset)
            make.centerX.equalToSuperview()
            make.width.equalTo(profileImageView.snp.height)
            make.height.equalToSuperview().multipliedBy(1.05/5.0)
        }
        
        emailTextField.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.4/6.0)
            let offset2 = UIScreen.main.bounds.width * (0.28/2.0)
            make.top.equalTo(profileImageView.snp.bottom).offset(offset1)
            make.left.equalToSuperview().inset(offset2)
            make.width.equalToSuperview().multipliedBy(1.1/2.0)
            make.height.equalToSuperview().multipliedBy(0.24/5.0)
        }
        

//        make.top.equalTo(profileImageView.snp.bottom).offset(20)
//          make.left.right.equalToSuperview().inset(50)
//          make.height.equalTo(44)
        
        checkEmailButton.snp.makeConstraints { make in
            let offset2 = UIScreen.main.bounds.width * (0.28/2.0)
            make.centerY.equalTo(emailTextField)
            make.right.equalToSuperview().inset(offset2)
            make.width.equalToSuperview().multipliedBy(0.3/2.0)
            make.height.equalToSuperview().multipliedBy(0.24/5.0)
        }

        emailValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.10/6.0)
            let offset2 = UIScreen.main.bounds.width * (0.28/2.0)
            make.top.equalTo(emailValidationLabel.snp.bottom).offset(offset1)
            make.left.right.equalToSuperview().inset(offset2)
            make.height.equalToSuperview().multipliedBy(0.24/5.0)
        }
        
        passwordValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.left.right.equalTo(passwordTextField)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.10/6.0)
            let offset2 = UIScreen.main.bounds.width * (0.28/2.0)
            make.top.equalTo(passwordValidationLabel.snp.bottom).offset(offset1)
            make.left.right.equalToSuperview().inset(offset2)
            make.height.equalToSuperview().multipliedBy(0.24/5.0)
        }
        
        confirmPasswordValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(5)
            make.left.right.equalTo(confirmPasswordTextField)
        }
        
        userNameTextField.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.10/6.0)
            let offset2 = UIScreen.main.bounds.width * (0.28/2.0)
            make.top.equalTo(confirmPasswordValidationLabel.snp.bottom).offset(offset1)
            make.left.right.equalToSuperview().inset(offset2)
            make.width.equalToSuperview().multipliedBy(1.1/2.0)
            make.height.equalToSuperview().multipliedBy(0.24/5.0)
        }
        
        checkUserNameButton.snp.makeConstraints { make in
            let offset2 = UIScreen.main.bounds.width * (0.28/2.0)
            make.centerY.equalTo(userNameTextField)
            make.right.equalToSuperview().inset(offset2)
            make.width.equalToSuperview().multipliedBy(0.3/2.0)
            make.height.equalToSuperview().multipliedBy(0.24/5.0)
        }
        
        userNameValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(5)
            make.left.right.equalTo(userNameTextField)
        }
        
        signUpButton.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.width * (0.28/2.0)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(offset)
            make.height.equalToSuperview().multipliedBy(0.24/5.0)
            make.bottom.equalToSuperview().multipliedBy(4.07/5.0)
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
        textField.isSecureTextEntry = isSecure // 패스워드 가리기
        textField.layer.cornerRadius = 10 // 모서리를 둥글게 만듭니다.
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1 // 선의 너비를 설정합니다.
        textField.layer.borderColor = UIColor.systemGray5.cgColor // 선의 색상을 설정합니다.
        textField.font = UIFont.pretendardRegular(ofSize: 16)
        textField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        // 왼쪽 공백을 추가합니다.
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        // 오른쪽 공백을 추가합니다.
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        view.addSubview(textField)
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
                // 중복 확인이 실패한 경우, 버튼 색상 및 테두리 색상을 원래대로 돌려야 합니다.
                self.checkEmailButton.setTitleColor(UIColor(hex: "#FF3A4A"), for: .normal)
                self.checkEmailButton.layer.borderColor = UIColor(hex: "#FF3A4A").cgColor
            } else {
                self.emailValidationLabel.text = "이메일 확인이 완료 되었습니다."
                self.emailValidationLabel.textColor = .gray
                // 중복 확인이 성공한 경우, 버튼 색상 및 테두리 색상을 변경합니다.
                self.checkEmailButton.setTitleColor(.systemGreen, for: .normal)
                self.checkEmailButton.layer.borderColor = UIColor.systemGreen.cgColor
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
                self.checkUserNameButton.setTitleColor(.systemGreen, for: .normal)
                self.checkUserNameButton.layer.borderColor = UIColor.systemGreen.cgColor
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
        
        // 비밀번호 강도 검사
        guard isPasswordStrong(password) else {
            presentAlert(title: "비밀번호 오류", message: "비밀번호는 8자 이상이어야 합니다.")

            return
        }
        // 각각의 중복 확인을 수행하고, 중복 여부를 확인하는 변수 추가
        let isEmailValidated = emailValidationLabel.text == "이메일 확인이 완료 되었습니다."
        let isUserNameValidated = userNameValidationLabel.text == "닉네임 확인이 완료 되었습니다."
        
        // 이메일과 닉네임 중복 확인이 모두 완료되지 않은 경우
        guard isEmailValidated && isUserNameValidated else {
            var message = ""
            if !isEmailValidated && !isUserNameValidated {
                message = "이메일 및 닉네임 중복 확인이 필요합니다."
            } else if !isEmailValidated {
                message = "이메일 중복 확인이 필요합니다."
            } else {
                message = "닉네임 중복 확인이 필요합니다."
            }
            presentAlert(title: "중복 확인 필요", message: message)
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
                let mainTabBarController = NewUserViewController()
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

extension SignUpViewController: UITextFieldDelegate {
    // UITextFieldDelegate 프로토콜의 textFieldShouldReturn 메서드 구현
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 텍스트 입력이 변경될 때마다 로그인 버튼의 색상을 업데이트합니다.
        updateSignUpButton()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSignUpButton()
    }
    private func updateSignUpButton() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              let userName = userNameTextField.text, !userName.isEmpty else {
            signUpButton.setTitleColor(UIColor(hex: "#C82D6B"), for: .normal)
            signUpButton.backgroundColor = .clear
            signUpButton.layer.borderWidth = 1.5
            signUpButton.layer.borderColor = UIColor(hex: "#C82D6B").cgColor
            return
        }
            signUpButton.setTitleColor(.white, for: .normal)
            signUpButton.layer.borderWidth = 0
            signUpButton.layer.borderColor = UIColor.clear.cgColor
            signUpButton.layer.cornerRadius = 16
            signUpButton.setInstagram()
        }
    }
    
#if DEBUG
    
    import SwiftUI
    
    //UIViewControllerRepresentable는 SwiftUI내에서 UIViewController를 사용할 수 있게 해줌
    struct ViewControllerPresentable : UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            SignUpViewController()
        }
    }
    
    // 미리보기 제공
    struct ViewControllerPresentable_PreviewProvider : PreviewProvider {
        static var previews: some View{
            ViewControllerPresentable()
        }
    }
    
    
#endif
