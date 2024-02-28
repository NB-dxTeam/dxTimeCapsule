import UIKit
import SnapKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let logoImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let signUpLabel = UILabel()
    private let signUpButton = UIButton(type: .system)
    private let dividerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupLayouts()
        
        // Test 자동기입
//        let testEmail = "admin@time.co.kr"
//        let testPassword = "123456"
//        
//        emailTextField.text = testEmail
//        passwordTextField.text = testPassword
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 버튼에 그라데이션 적용
        loginButton.applyGradient(colors: [#colorLiteral(red: 0.7882352941, green: 0.2941176471, blue: 0.2941176471, alpha: 1), #colorLiteral(red: 0.2941176471, green: 0.07450980392, blue: 0.3098039216, alpha: 1)])
    }

    private func setupViews() {
        // 로그인 이미지 설정
        logoImageView.image = UIImage(named: "LoginLogo")
        
        // 앱 이름 설정
        appNameLabel.text = "dxCapsule"
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 36) // 적절한 폰트 및 크기로 설정
        appNameLabel.textAlignment = .center
        
        // 이메일 텍스트필드 설정
        configureTextField(emailTextField, placeholder: "Enter your email")

        // 비밀번호 텍스트필드 설정
        configureTextField(passwordTextField, placeholder: "Enter your password")

        // 로그인 버튼 설정 및 액션 연결
        configureButton(loginButton, title: "Login")
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        // 회원가입 레이블 설정
        configureSignUpLabel()
        
        // 회원가입 버튼 설정 및 액션 연결
        configureButton(signUpButton, title: "Sign Up")
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(dividerView)
        
    }
    
    private func setupLayouts() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(220)
            
        }
        
        // 앱 이름 레이블 레이아웃 설정
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20) // 로고 이미지 아래에 배치
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30) // 왼쪽 여백 추가
            make.right.equalToSuperview().offset(-30) // 오른쪽 여백 추가
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.right.equalTo(passwordTextField)
            make.height.equalTo(44)
        }
        
        signUpLabel.snp.makeConstraints { make in
            make.bottom.equalTo(dividerView.snp.top).offset(-8) // 이 부분이 수정되었습니다.
            make.centerX.equalToSuperview()
        }
        
        signUpButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
        }
        
        dividerView.backgroundColor = .lightGray
        dividerView.snp.makeConstraints { make in
            make.bottom.equalTo(signUpButton.snp.top) // 이 부분이 수정되었습니다.
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        
    }
    
    // MARK: - Actions
    
    // 로그인 버튼 탭 처리
    @objc private func didTapLoginButton() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "입력 오류", message: "이메일 또는 비밀번호를 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    // 로그인 실패: 에러 메시지 처리 및 알림 표시
                    let alert = UIAlertController(title: "로그인 실패", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                } else {
                    // 로그인 성공: 성공 메시지 표시 및 메인 피드 화면으로 전환
                    let alert = UIAlertController(title: "로그인 성공", message: "로그인 되었습니다", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        
                        let mainFeedVC = SearchUserViewController()
                        // 네비게이션 컨트롤러가 있는 경우
                        self.navigationController?.pushViewController(mainFeedVC, animated: true)
                        // 네비게이션 컨트롤러가 없는 경우
                        //                         self.present(mainFeedVC, animated: true, completion: nil)
                    })
                    self.present(alert, animated: true)
                    
                }
            }
        }
    }
    
    // 회원가입 버튼 탭 처리
    @objc private func didTapSignUpButton() {
        let signUpViewController = SignUpViewController()
        let navigationController = UINavigationController(rootViewController: signUpViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

// 텍스트 필드 스타일 설정 함수
private extension LoginViewController {
    func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.layer.backgroundColor = UIColor.systemGray6.cgColor
        textField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    func configureButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    func configureSignUpLabel() {
        signUpLabel.text = "Do not have an account? Sign Up"
        signUpLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        signUpLabel.textAlignment = .center
        view.addSubview(signUpLabel) // signUpLabel 추가
        
        signUpLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20) // 뷰의 하단에 추가
            make.centerX.equalToSuperview()
        }
    }
}

// 버튼 그라데이션 적용 확장
extension UIButton {
    func applyGradient(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds // 여기를 수정함
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = self.layer.cornerRadius
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// UITextField 패딩 추가를 위한 확장
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
