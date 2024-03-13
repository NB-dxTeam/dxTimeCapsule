import UIKit
import SnapKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn


class LoginViewController: UIViewController {
    
    // 리스너 핸들을 저장하기 위한 변수 선언
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    private let labelsContainerView = UIView()
    private let logoImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let socialLogin = UIButton(type: .system)
    private let signUpLabel = UILabel()
    private let signUpButton = UIButton(type: .system)
    private let dividerView = UIView()
    
    private let noAccountLabel = UILabel() // "계정이 없으신가요?" 라벨
    private let signUpActionLabel = UILabel() // "회원가입" 액션 라벨
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSignUpButtonAction() // 회원가입 버튼의 액션을 설정하는 메서드 호출
        setupViews()
        setupLayouts()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Test 자동기입
        emailTextField.text =  "test1@gmail.com"
        passwordTextField.text = "123456"
        
    }
    
    private func setupSignUpButtonAction() {
        // 회원가입 버튼의 액션 설정
        signUpActionLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSignUpLabel))
        signUpActionLabel.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        loginButton.backgroundColor = UIColor(hex: "#FF3A4A")
//        socialLogin.backgroundColor = UIColor(hex: "#FF3A4A")
        loginButton.setInstagram()
        socialLogin.setInstagram()

    }
    
    deinit {
        // 리스너 제거
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(dividerView)
        view.addSubview(labelsContainerView)
        view.addSubview(socialLogin)

        
        // labelsContainerView 내에 라벨들을 추가
        labelsContainerView.addSubview(noAccountLabel)
        labelsContainerView.addSubview(signUpActionLabel)
        
        // 로그인 이미지 설정
        logoImageView.image = UIImage(named: "AppMainLogo")
        
        
        // 앱 이름 설정
        appNameLabel.text = "Memorium"
        appNameLabel.font = UIFont.proximaNovaBold(ofSize: 44)
        appNameLabel.textAlignment = .center
        
        // 이메일 텍스트필드 설정
        configureTextField(emailTextField, placeholder: "Enter your email")
        
        // 비밀번호 텍스트필드 설정
        configureTextField(passwordTextField, placeholder: "Enter your password")
        
        // 로그인 버튼 설정 및 액션 연결ㅐ
        configureButton(loginButton, title: "Login")
        configureButton(socialLogin, title: "Social Login")
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        socialLogin.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)

        // "계정이 없으신가요?" 라벨 설정
        noAccountLabel.text = "Do not have an account?"
        noAccountLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
        noAccountLabel.textColor = .black
        
        // "회원가입" 라벨 &설정
        signUpActionLabel.text = "Sign up !"
        signUpActionLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
        signUpActionLabel.textColor = UIColor(hex: "#C82D6B")
        signUpActionLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSignUpLabel))
        signUpActionLabel.addGestureRecognizer(tapGesture)
        
        // 디바이더 뷰 셋업
        dividerView.backgroundColor = .lightGray
        
    }
    
    // MARK: - Setup Layouts
    private func setupLayouts() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        passwordTextField.isSecureTextEntry = true
        
        
        // loginButton
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.right.equalTo(passwordTextField)
            make.height.equalTo(44)
        }
        
        // Google 로그인 버튼 레이아웃 설정
        socialLogin.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.width.equalTo(loginButton.snp.width)
            make.height.equalTo(44)
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
        
        // noAccountLabel 및 signUpActionLabel에 대한 레이아웃 설정
        noAccountLabel.snp.makeConstraints { make in
            make.left.equalTo(labelsContainerView.snp.left)
            make.centerY.equalTo(labelsContainerView.snp.centerY)
        }
        
        signUpActionLabel.snp.makeConstraints { make in
            make.right.equalTo(labelsContainerView.snp.right)
            make.centerY.equalTo(labelsContainerView.snp.centerY)
            make.left.equalTo(noAccountLabel.snp.right).offset(5)
        }
        
        // 디버깅을 위한 배경색 설정
        //        labelsContainerView.backgroundColor = .green // labelsContainerView의 배경색 설정
        //        noAccountLabel.backgroundColor = .red // noAccountLabel의 배경색 설정
        //        signUpActionLabel.backgroundColor = .blue // signUpActionLabel의 배경색 설정
        
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
                    print("Login failed with error: \(error.localizedDescription)") // Debug print
                    
                    // 로그인 실패: 에러 메시지 처리 및 알림 표시
                    let alert = UIAlertController(title: "로그인 실패", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                } else {
                    print("Login succeeded") // Debug print
                    let mainTabVC = MainTabBarView()
                    mainTabVC.modalPresentationStyle = .fullScreen
                       self.present(mainTabVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    // 회원가입 버튼 탭 처리
    @objc private func didTapSignUpLabel() {
        let signUpViewController = SignUpViewController()
        self.present(signUpViewController, animated: true, completion: nil)
        print("Sign Up Button Tapped")
        
    }
    
    @objc private func handleGoogleSignIn() {
        
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
        textField.font = UIFont.pretendardRegular(ofSize: 14)
        textField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    func configureButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        
        // 그림자 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 6 // 그림자의 블러 정도 설정 (조금 더 부드럽게)
        button.layer.shadowOpacity = 0.3 // 그림자의 투명도 설정 (적당한 농도로)
        button.layer.shadowOffset =  CGSize(width: 0, height: 3) // 그림자 방향 설정 (아래로 조금 더 멀리)
        
        
        button.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }

    func configureSignUpLabel() {
        signUpLabel.text = "Do not have an account? Sign Up"
        signUpLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
        signUpLabel.textAlignment = .center
    }
}

extension LoginViewController: UITextFieldDelegate {
    // UITextFieldDelegate 프로토콜의 textFieldShouldReturn 메서드 구현
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 키보드의 리턴(엔터) 키를 눌렀을 때 로그인 버튼의 동작 실행
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder() // 비밀번호 텍스트 필드로 포커스 이동
        } else if textField == passwordTextField {
            textField.resignFirstResponder() // 키보드 감추기
            didTapLoginButton() // 로그인 버튼의 액션 실행
        }
        return true
    }
}


// MARK: - SwiftUI Preview
import SwiftUI

//struct MainTabBarViewPreview22 : PreviewProvider {
//    static var previews: some View {
//        LoginViewController().toPreview()
//    }
//}
