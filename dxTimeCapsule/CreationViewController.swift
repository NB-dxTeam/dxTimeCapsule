import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class CreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Components
    private let photoPlaceholderView = UIView()
    private let photoPlaceholderLabel = UILabel()
    private let uploadPhotoButton = UIButton()
    private let locationInputButton = UIButton()
    private let capsuleContentTextField = UITextField()
    private let openDateLabel = UILabel()
    private let openDatePicker = UIDatePicker()
    private let saveButton = UIButton()
    private let createDummyDataButton = UIButton() // 더미 버튼
    private let requestButton = UIButton()
    private let acceptButton = UIButton()
    private let friendEmailOrNicknameTextField = UITextField()
    private let sendFriendRequestButton = UIButton(type: .system)
    private let friendsViewmodel = FriendsViewModel()
    private var selectedImage: UIImage? {
        
        didSet {
//            updatePhotoPlaceholder()
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
//        setupCreateDummyDataButton() // 더미 데이터 생성 버튼 설정 메서드 호출
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
//        setupSaveButton()
        setupFriendEmailOrNicknameTextField()
        setupSendFriendRequestButton()
    }

    private func setupFriendEmailOrNicknameTextField() {
        friendEmailOrNicknameTextField.placeholder = "친구의 이메일 또는 닉네임 입력"
        view.addSubview(friendEmailOrNicknameTextField)
        friendEmailOrNicknameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(acceptButton.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
    }

    private func setupSendFriendRequestButton() {
        sendFriendRequestButton.setTitle("친구 신청 보내기", for: .normal)
        sendFriendRequestButton.backgroundColor = .systemBlue
        sendFriendRequestButton.setTitleColor(.white, for: .normal)
        sendFriendRequestButton.layer.cornerRadius = 10
        view.addSubview(sendFriendRequestButton)
        
        sendFriendRequestButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(friendEmailOrNicknameTextField.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }

    // 친구 요청 보내기 버튼 액션
    @objc func sendFriendRequestButtonTapped() {
        guard let query = friendEmailOrNicknameTextField.text, !query.isEmpty else {
            print("친구 이메일 또는 닉네임을 입력해주세요.")
            return
        }
        
        friendsViewmodel.searchUser(byEmailOrNickname: query) { [weak self] users in
            guard let self = self else { return }
            
            // 이 예제에서는 단순화를 위해 첫 번째 검색 결과에 대해서만 친구 요청을 보냅니다.
            if let user = users.first {
//                self.friendsViewmodel.sendFriendRequest(toUserId: user.id, fromUser: currentUser) // `currentUser`는 현재 로그인한 사용자의 정보를 담은 User 객체입니다.
                print("친구 요청을 보냈습니다: \(query)")
            } else {
                print("사용자를 찾을 수 없습니다: \(query)")
            }
        }
    }


    // 친구 요청 수락하기 버튼 액션
    

}
