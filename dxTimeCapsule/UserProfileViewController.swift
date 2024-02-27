//
//  UserProfileViewController.swift
//  dxTimeCapsule
//
//  Created by Lee HyeKyung on 2024/02/27.
//

import UIKit
import SnapKit
import SwiftUI

class UserProfileViewController: UIViewController {
    var userViewModel: UserProfileViewModel!
    
    // UI Components
    var profileImageView: UIImageView!
    var nameLabel: UILabel!
    var emailLabel: UILabel!
    var friendsLabel: UILabel!
    var friendTagsLabel: UILabel!
    var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        bindViewModel()
        setupDeleteAccountButton()
        
    }
    
    private func setupViews() {
        profileImageView = UIImageView()
        nameLabel = UILabel()
        emailLabel = UILabel()
        friendsLabel = UILabel()
        friendTagsLabel = UILabel()
        
        // Profile Image View
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemMint
        view.addSubview(profileImageView)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(UIScreen.main.bounds.height * 0.10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        // Name Label
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        // Email Label
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(emailLabel)
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        // Friends Label
        friendsLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(friendsLabel)
        
        friendsLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        // Friend Tags Label
        friendTagsLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(friendTagsLabel)
        
        friendTagsLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        User.getCurrentUser { [weak self] user in
            DispatchQueue.main.async {
                // 메인 스레드에서 UI 업데이트
                if let user = user {
                    self?.profileImageView.image = UIImage(contentsOfFile: "defaultProfileImage")
                    self?.nameLabel.text = user.id
                    self?.emailLabel.text = user.email
                    
                    // 기타 사용자 정보를 UI에 반영하는 코드...
                } else {
                    // 사용자 정보를 불러오지 못한 경우, 에러 처리
                    // 예: 사용자 정보 없음 메시지 표시
                }
            }
        }
       // deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
     }

    
    private func setupDeleteAccountButton() {
        deleteAccountButton = UIButton()
        deleteAccountButton.setTitle("회원 탈퇴하기", for: .normal)
        deleteAccountButton.backgroundColor = .systemMint
        deleteAccountButton.layer.cornerRadius = 5
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        
        view.addSubview(deleteAccountButton)
        deleteAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    @objc private func deleteAccountTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "회원 탈퇴", message: "정말로 탈퇴하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive, handler: { [weak self] _ in
            self?.userViewModel.deleteUserAccount { success in
                DispatchQueue.main.async {
                    if success {
                        // 성공적으로 탈퇴 처리되었을 때의 로직
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        // 탈퇴 처리 중 오류 발생 시
                        let alert = UIAlertController(title: "탈퇴 처리 중 오류 발생", message: "다시 시도해 주세요.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}



#if DEBUG

import SwiftUI

//UIViewControllerRepresentable는 SwiftUI내에서 UIViewController를 사용할 수 있게 해줌
struct UserProfileViewControllerPresentable : UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        UserProfileViewController()
    }
}

// 미리보기 제공
struct UserProfileViewControllerPresentable_PreviewProvider : PreviewProvider {
    static var previews: some View{
        UserProfileViewControllerPresentable()
    }
}
#endif
