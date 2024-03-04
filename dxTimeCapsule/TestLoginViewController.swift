//import UIKit
//import FirebaseAuth
//
//class LoginTestViewController: UIViewController {
//    
//    // MARK: - Properties
//    private let emailTextField = UITextField()
//    private let passwordTextField = UITextField()
//    private let loginButton = UIButton(type: .system)
//    private let signUpButton = UIButton(type: .system)
//    private let imageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        configureUIComponents()
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        view.backgroundColor = .white
//        
//        imageView.contentMode = .scaleAspectFit
//        view.addSubview(imageView)
//        
//        emailTextField.placeholder = "이메일"
//        emailTextField.borderStyle = .roundedRect
//        view.addSubview(emailTextField)
//        
//        passwordTextField.placeholder = "비밀번호"
//        passwordTextField.isSecureTextEntry = true
//        passwordTextField.borderStyle = .roundedRect
//        view.addSubview(passwordTextField)
//        
//        // Additional setup like constraints goes here...
//    }
//    
//    private func configureUIComponents() {
//        setupButton(loginButton, title: "로그인", backgroundColor: .systemBlue, selector: #selector(didTapLoginButton))
////        setupButton(signUpButton, title: "회원가입", backgroundColor: .systemBlue, selector: #selector(didTapSignUpLabel))
//        
//        // Add buttons to the view and set up constraints here...
//    }
//    
//    private func setupButton(_ button: UIButton, title: String, backgroundColor: UIColor, selector: Selector) {
//        button.setTitle(title, for: .normal)
//        button.backgroundColor = backgroundColor
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 10
//        button.addTarget(self, action: selector, for: .touchUpInside)
//        view.addSubview(button)
//        
//        // Set up button constraints here...
//    }
//    
//    // MARK: - Actions
//    @objc private func didTapLoginButton() {
//        guard let email = emailTextField.text, !email.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            showAlert(with: "이메일 또는 비밀번호를 입력해주세요.", title: "입력 오류")
//            return
//        }
//        
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
//            guard let self = self else { return }
//            if let error = error {
//                self.showAlert(with: error.localizedDescription, title: "로그인 실패")
//            } else {
//                self.showAlert(with: "로그인 되었습니다", title: "로그인 성공")
//                // Proceed to navigate to the main feed or perform a segue...
//            }
//        }
//    }
//    
//    @objc private func didTapSignUpButton() {
//        // Navigate to the sign-up screen...
//    }
//    
//    private func showAlert(with message: String, title: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "확인", style: .default))
//        present(alert, animated: true)
//    }
//}
