//
//  SignUpOptionViewController.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 3/19/24.
//

import UIKit
import GoogleSignIn

class SignUpOptionViewController: UIViewController {
    
    // 모달 컨테이너의 높이를 계산하기 위한 비율 상수
    let modalHeightRatio: CGFloat = 0.5
    
    // 모달 컨테이너 뷰
    let modalView = UIView()
    
    // email 스택뷰
    lazy var emailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.addArrangedSubview(self.emailLogo)
        stackView.addArrangedSubview(self.emailLabel)
        return stackView
    }()
    
    let emailLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName:"envelope"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true
        return imageView
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일로 시작하기"
        label.textColor = UIColor(hex: "#000000")
        label.font = UIFont.pretendardSemiBold(ofSize: 16)
        return label
    }()
    
    // kakao 스택뷰
    lazy var kakaoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.addArrangedSubview(self.kakaoLogo)
        stackView.addArrangedSubview(self.kakaoLabel)
        return stackView
    }()
    
    let kakaoLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "KakaoLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true
        return imageView
    }()
    
    let kakaoLabel: UILabel = {
        let label = UILabel()
        label.text = "카카오로 시작하기"
        label.textColor = UIColor(hex: "#000000")
        label.font = UIFont.pretendardSemiBold(ofSize: 16)
        return label
    }()
    
    // naver 스택뷰
    lazy var naverStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.addArrangedSubview(self.naverLogo)
        stackView.addArrangedSubview(self.naverLabel)
        return stackView
    }()
    
    let naverLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "naverLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true // 이미지 높이를 버튼 높이와 동일하게 설정
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true // 이미지의 가로와 세로 길이를 동일하게 설정
        return imageView
    }()
    
    let naverLabel: UILabel = {
        let label = UILabel()
        label.text = "네이버로 시작하기"
        label.textColor = UIColor(hex: "#F1F1F2")
        label.font = UIFont.pretendardSemiBold(ofSize: 16)
        return label
    }()
    
    // google 스택뷰
    lazy var googleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.addArrangedSubview(self.googleLogo)
        stackView.addArrangedSubview(self.googleLabel)
        return stackView
    }()
    
    let googleLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "GoogleLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true
        return imageView
    }()
    
    let googleLabel: UILabel = {
        let label = UILabel()
        label.text = "Google로 시작하기"
        label.textColor = UIColor(hex: "#000000")
        label.font = UIFont.pretendardSemiBold(ofSize: 16)
        return label
    }()
    
    // apple 스택뷰
    lazy var appleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.addArrangedSubview(self.appleLogo)
        stackView.addArrangedSubview(self.appleLabel)
        return stackView
    }()
    
    let appleLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "AppleLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true
        return imageView
    }()
    
    let appleLabel: UILabel = {
        let label = UILabel()
        label.text = "Apple로 시작하기"
        label.textColor = UIColor(hex: "#F1F1F2")
        label.font = UIFont.pretendardSemiBold(ofSize: 16)
        return label
    }()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 모달 컨테이너 뷰 설정
        setupModalView()
    }
    
    private func setupModalView() {
        // 모달 컨테이너 뷰의 높이 설정
        let modalHeight: CGFloat = view.frame.height * modalHeightRatio
        modalView.frame = CGRect(x: 0, y: view.frame.height - modalHeight, width: view.frame.width, height: modalHeight)
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 20
        modalView.layer.masksToBounds = true
        view.addSubview(modalView)
        
        // 로그인 옵션 버튼 생성 및 추가
        setupSignUpOptionButtons()
        
        // 핸들 뷰 추가
        let handleView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 5))
        handleView.backgroundColor = .gray
        handleView.layer.cornerRadius = 2.5
        handleView.center.x = modalView.center.x
        handleView.frame.origin.y = 10 // 모달 뷰의 상단에서 10 포인트 아래에 위치하도록 조정
        modalView.addSubview(handleView)
    }
    
    private func setupSignUpOptionButtons() {

        // 이메일로 시작하기 버튼
           let emailButton = UIButton(type: .system)
           emailButton.layer.cornerRadius = 12
           emailButton.layer.borderWidth = 1 // 라인의 너비 설정
           emailButton.layer.borderColor = UIColor.systemGray3.cgColor
           emailButton.frame = CGRect(x: 20, y: 40, width: modalView.frame.width - 40, height: 40)
           emailButton.addTarget(self, action: #selector(emailSignUpButtonTapped), for: .touchUpInside)
           modalView.addSubview(emailButton)
        
        // email 스택뷰를 버튼에 추가
        emailButton.addSubview(emailStackView)

        // email 스택뷰의 제약 조건 설정
        emailStackView.translatesAutoresizingMaskIntoConstraints = false
        emailStackView.centerXAnchor.constraint(equalTo: emailButton.centerXAnchor).isActive = true
        emailStackView.centerYAnchor.constraint(equalTo: emailButton.centerYAnchor).isActive = true

        // 카카오로 시작하기 버튼
           let kakaoButton = UIButton(type: .system)
           kakaoButton.layer.cornerRadius = 12
           kakaoButton.backgroundColor = UIColor(hex: "#FEE500")
           kakaoButton.frame = CGRect(x: 20, y: emailButton.frame.maxY + 20, width: modalView.frame.width - 40, height: 40)
           kakaoButton.addTarget(self, action: #selector(kakaoSignUpButtonTapped), for: .touchUpInside)
           modalView.addSubview(kakaoButton)
        
        // kakao 스택뷰를 버튼에 추가
        kakaoButton.addSubview(kakaoStackView)

        // kakao 스택뷰의 제약 조건 설정
        kakaoStackView.translatesAutoresizingMaskIntoConstraints = false
        kakaoStackView.centerXAnchor.constraint(equalTo: kakaoButton.centerXAnchor).isActive = true
        kakaoStackView.centerYAnchor.constraint(equalTo: kakaoButton.centerYAnchor).isActive = true
        
        
        // 네이버로 시작하기 버튼
        let naverButton = UIButton(type: .system)
        naverButton.layer.cornerRadius = 12
        naverButton.backgroundColor = UIColor(hex: "#03C75A")
        naverButton.frame = CGRect(x: 20, y: kakaoButton.frame.maxY + 20, width: modalView.frame.width - 40, height: 40)
        naverButton.addTarget(self, action: #selector(naverSignUpButtonTapped), for: .touchUpInside)
        modalView.addSubview(naverButton)
        
        // naver 스택뷰를 버튼에 추가
        naverButton.addSubview(naverStackView)

        // naver 스택뷰의 제약 조건 설정
        naverStackView.translatesAutoresizingMaskIntoConstraints = false
        naverStackView.centerXAnchor.constraint(equalTo: naverButton.centerXAnchor).isActive = true
        naverStackView.centerYAnchor.constraint(equalTo: naverButton.centerYAnchor).isActive = true
        
        
        // Google로 시작하기 버튼
           let googleButton = UIButton(type: .system)
           googleButton.layer.cornerRadius = 12
           googleButton.layer.borderWidth = 1 // 라인의 너비 설정
           googleButton.layer.borderColor = UIColor.systemGray3.cgColor
           googleButton.frame = CGRect(x: 20, y: naverButton.frame.maxY + 20, width: modalView.frame.width - 40, height: 40)
           googleButton.addTarget(self, action: #selector(googleSignUpButtonTapped), for: .touchUpInside)
           modalView.addSubview(googleButton)
        
        // Google 스택뷰를 버튼에 추가
        googleButton.addSubview(googleStackView)

        // Google 스택뷰의 제약 조건 설정
        googleStackView.translatesAutoresizingMaskIntoConstraints = false
        googleStackView.centerXAnchor.constraint(equalTo: googleButton.centerXAnchor).isActive = true
        googleStackView.centerYAnchor.constraint(equalTo: googleButton.centerYAnchor).isActive = true
        
        // Apple로 시작하기 버튼
           let appleButton = UIButton(type: .system)
           appleButton.layer.cornerRadius = 12
           appleButton.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
           appleButton.backgroundColor = UIColor.black
           appleButton.frame = CGRect(x: 20, y: googleButton.frame.maxY + 20, width: modalView.frame.width - 40, height: 40)
           appleButton.addTarget(self, action: #selector(appleSignUpButtonTapped), for: .touchUpInside)
           modalView.addSubview(appleButton)
        
        // Apple 스택뷰를 버튼에 추가
        appleButton.addSubview(appleStackView)

        // Apple 스택뷰의 제약 조건 설정
        appleStackView.translatesAutoresizingMaskIntoConstraints = false
        appleStackView.centerXAnchor.constraint(equalTo: appleButton.centerXAnchor).isActive = true
        appleStackView.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor).isActive = true
        
       }
    
    // MARK: - Actions
    
       @objc func emailSignUpButtonTapped() {
           print("이메일로 시작하기 버튼이 눌렸습니다.")
           let signUpViewController = SignUpViewController()
           self.present(signUpViewController, animated: true, completion: nil)
       }
       
       @objc func kakaoSignUpButtonTapped() {
           print("카카오로 시작하기 버튼이 눌렸습니다.")
       }
       
       @objc func naverSignUpButtonTapped() {
           print("네이버로 시작하기 버튼이 눌렸습니다.")
       }
       
       @objc func googleSignUpButtonTapped() {
           print("Google로 시작하기 버튼이 눌렸습니다.")
       }
       
       @objc func appleSignUpButtonTapped() {
           print("Apple로 시작하기 버튼이 눌렸습니다.")
//           let provider = ASAuthorizationAppleIDProvider()
//           let request = provider.createRequest()
//           request.requestedScopes = [.fullName, .email]
//
//           let controller = ASAuthorizationController(authorizationRequests: [request])
//           controller.delegate = self
//           controller.presentationContextProvider = self
//           controller.performRequests()
       }
   }

import SwiftUI
struct PreView73: PreviewProvider {
    static var previews: some View {
        SignUpOptionViewController().toPreview()
    }
}
