import UIKit
import FirebaseFirestore
import FirebaseAuth
import SnapKit

class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let nameTextField = UITextField()
    private let signUpButton = UIButton(type: .system)
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        emailTextField.placeholder = "이메일"
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.isSecureTextEntry = true
        nameTextField.placeholder = "이름"
        
        signUpButton.setTitle("회원가입", for: .normal)
        signUpButton.backgroundColor = .systemBlue
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 10
        
        // 회원가입 버튼 액션 추가
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, nameTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        [emailTextField, passwordTextField, nameTextField, signUpButton].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
        }
    }
    
    
    // MARK: - Navigation Bar Setup
    
    private func setupNavigationBar() {
        navigationItem.title = "회원가입"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
    }


    
    // MARK: - Actions
    
    // 회원가입 함수
    @objc private func signUp() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let nickname = nameTextField.text, !nickname.isEmpty else {
            presentAlert(title: "입력 오류", message: "모든 필드를 채워주세요.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.presentAlert(title: "회원가입 실패", message: error.localizedDescription)
                return
            }

            guard let userId = authResult?.user.uid else { return }
            let userDocument = Firestore.firestore().collection("users").document(userId)

            // 사용자 정보를 Firestore에 저장합니다. 친구 기능을 위해 필요한 필드를 추가할 수 있습니다.
            userDocument.setData([
                "nickname": nickname, // 닉네임
                "email": email, // 이메일
                "profileImageUrl": "", // 프로필 이미지 URL,
                "friends": [], // 친구 UID 목록, 친구 추가 기능을 통해 업데이트
                // 필요한 추가 정보
            ]) { error in
                if let error = error {
                    self.presentAlert(title: "정보 저장 실패", message: error.localizedDescription)
                } else {
                    // 회원가입 성공 알림 후 이전 화면으로 돌아가기
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "회원가입 성공", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                            // 네비게이션 컨트롤러를 사용하는 경우
//                            self.navigationController?.popViewController(animated: true)
                            // 모달 방식으로 표시된 경우
                             self.dismiss(animated: true, completion: nil)
                        })
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }


    // Alert
    private func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
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

}
