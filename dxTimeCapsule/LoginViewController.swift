import UIKit
import SnapKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    // 리스너 핸들을 저장하기 위한 변수 선언
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    private let labelsContainerView = UIView()
    private let logoImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    
    private let loginButton : UIButton = {
        let button = UIButton(type: .system)
        let title = "Login" // 버튼의 제목 설정
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        // 그림자 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 6 // 그림자의 블러 정도 설정 (조금 더 부드럽게)
        button.layer.shadowOpacity = 0.3 // 그림자의 투명도 설정 (적당한 농도로)
        button.layer.shadowOffset =  CGSize(width: 0, height: 3) // 그림자
        return button
    }()
    
    private let signUpButton : UIButton = {
        let button = UIButton(type: .system)
        let title = "Sign up" // 버튼의 제목 설정
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(hex: "#C82D6B"), for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        button.layer.borderWidth = 1.5 // 라인의 너비 설정
        button.layer.borderColor = UIColor(hex: "#C82D6B").cgColor
        
        return button
    }()
    
    private let signUpLabel = UILabel()
    private let forgot = UIButton(type: .system)
    private let dividerView = UIView()
    private let forgotPWLabel = UILabel() // "회원가입" 액션 라벨
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSignUpButtonAction() // 회원가입 버튼의 액션을 설정하는 메서드 호출
        setupViews()
        setupLayouts()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Test 자동기입
        emailTextField.text =  "test4@gmail.com"
        passwordTextField.text = "12345678"
    }
    
    private func setupSignUpButtonAction() {
        // 회원가입 버튼의 액션 설정
        forgotPWLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapForgotPWLabel))
        forgotPWLabel.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //        loginButton.backgroundColor = UIColor(hex: "#FF3A4A")
        //        socialLogin.backgroundColor = UIColor(hex: "#FF3A4A")
        loginButton.setInstagram()
        loginButton.layer.cornerRadius = 16
 
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
        view.addSubview(signUpButton)
        view.addSubview(forgotPWLabel)
        
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
        configureButton(signUpButton, title: "Sign up")
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        
        // "비밀번호 찾기" 라벨 &설정
        forgotPWLabel.text = "Forgot Password? "
        forgotPWLabel.font = UIFont.pretendardMedium(ofSize: 14)
        forgotPWLabel.textColor = .black
        forgotPWLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapForgotPWLabel))
        forgotPWLabel.addGestureRecognizer(tapGesture)
        
        // 디바이더 뷰 셋업
        dividerView.backgroundColor = .lightGray
        
    }
    
    // MARK: - Setup Layouts
    private func setupLayouts() {
        logoImageView.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.45/6.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(offset)
            make.centerX.equalToSuperview()
            make.width.equalTo(logoImageView.snp.height)
            make.height.equalToSuperview().multipliedBy((2.15/6.0) * 0.7)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.6/6.0)
            make.top.equalTo(appNameLabel.snp.bottom).offset(offset)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        passwordTextField.isSecureTextEntry = true
        
        
        // 로그인 버튼 레이아웃 설정
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.right.equalTo(passwordTextField)
            make.height.equalTo(44)
        }
        
        // 회원가입 버튼 레이아웃 설정
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.width.equalTo(loginButton.snp.width)
            make.height.equalTo(44)
        }
        
        // dividerView 레이아웃 설정
        dividerView.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.45/6.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(offset)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }
        
        // labelsContainerView에 대한 높이 제약 조건 추가
        forgotPWLabel.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            // 높이를 명시적으로 설정
            make.height.equalTo(20)
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
                    print("Login failed with error: \(error.localizedDescription)") // Debug print
                    
                    // 로그인 실패: 에러 메시지 처리 및 알림 표시
                    let alert = UIAlertController(title: "로그인 실패", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                } else {
                    print("Login succeeded")
                    let mainTabVC = MainTabBarView()
                    mainTabVC.modalPresentationStyle = .fullScreen
                    self.present(mainTabVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    // 회원가입 버튼 탭 처리
    @objc private func didTapSignUpButton() {
        let signUpViewController = SignUpViewController()
        self.present(signUpViewController, animated: true, completion: nil)
        print("Sign Up Button Tapped")
    }
    
    // 비밀번호 재설정 버튼 탭 처리
    @objc private func didTapForgotPWLabel() {
        // 팝업 창 생성
        print("didTapForgotPWLabel")
        let alertController = UIAlertController(title: "비밀번호 재설정", message: "이메일 주소를 입력하세요.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "이메일"
        }
        
        // 확인 버튼 추가
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            // 사용자가 입력한 이메일 주소 가져오기
            if let email = alertController.textFields?.first?.text {
                // 이메일 주소가 비어있는지 확인
                guard !email.isEmpty else {
                    let alert = UIAlertController(title: "입력 오류", message: "이메일을 입력해주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                // Firestore 데이터베이스에서 이메일 확인
                let db = Firestore.firestore()
                let usersRef = db.collection("users")
                usersRef.whereField("email", isEqualTo: email).getDocuments { [weak self] (querySnapshot, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error getting documents: \(error)")
                        // 에러가 발생한 경우, 사용자에게 알림 표시
                        let alert = UIAlertController(title: "에러", message: "이메일 확인 중 오류가 발생했습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                    } else if querySnapshot?.documents.isEmpty == true {
                        // 이메일이 존재하지 않는 경우
                        let alert = UIAlertController(title: "이메일 없음", message: "해당하는 이메일이 존재하지 않습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "다시 시도", style: .default))
                        alert.addAction(UIAlertAction(title: "가입하기", style: .default) { _ in
                            // 가입하기 버튼을 누른 경우, 회원가입 화면으로 이동
                            self.didTapSignUpButton()
                        })
                        self.present(alert, animated: true)
                    } else {
                        // 이메일이 존재하는 경우, 비밀번호 재설정 이메일 보내기
                        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
                            guard let self = self else { return }
                            if let error = error {
                                print("Error sending password reset email: \(error.localizedDescription)")
                                // 에러가 발생한 경우, 사용자에게 알림 표시
                                let alert = UIAlertController(title: "에러", message: "비밀번호 재설정 이메일 보내기 중 오류가 발생했습니다.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .default))
                                self.present(alert, animated: true)
                            } else {
                                // 이메일이 성공적으로 보내진 경우, 사용자에게 알림 표시
                                let alert = UIAlertController(title: "이메일 전송 완료", message: "비밀번호 재설정 이메일을 보냈습니다. 이메일을 확인해주세요.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .default))
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            }
        }
        
        alertController.addAction(confirmAction) // 확인 액션 추가
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel)) // 취소 액션 추가
        self.present(alertController, animated: true)
    }
}
// 텍스트 필드 스타일 설정 함수
private extension LoginViewController {
    func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
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
    }
    
    func configureButton(_ button: UIButton, title: String) {
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

struct MainTabBarViewPreview : PreviewProvider {
    static var previews: some View {
        LoginViewController().toPreview()
    }
}
