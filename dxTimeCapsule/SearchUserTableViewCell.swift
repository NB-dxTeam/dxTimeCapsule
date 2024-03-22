import UIKit
import SnapKit
import SDWebImage
import FirebaseAuth

class SearchUserTableViewCell: UITableViewCell {
    var user: User?
    var friendsViewModel: FriendsViewModel?
    var friendActionButtonTapAction: (() -> Void)?  // 친구 추가/요청 버튼 탭 시 실행될 클로저
    var userProfileImageView: UIImageView!
    var userNameLabel: UILabel!
    var friendActionButton: UIButton! // 친구 추가 또는 요청 수락 버튼
    var statusLabel: UILabel! // 상태를 나타내는 레이블
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    
    private func setupUI() {
        
        userProfileImageView = UIImageView()
        userProfileImageView.layer.cornerRadius = 25
        userProfileImageView.clipsToBounds = true
        userProfileImageView.setRoundedImage()
        
        contentView.addSubview(userProfileImageView)
        
        //
        userNameLabel = UILabel()
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        contentView.addSubview(userNameLabel)
        
        // 친구 추가/요청 버튼 초기화
        friendActionButton = UIButton(type: .system)
        friendActionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        friendActionButton.layer.cornerRadius = 10
        friendActionButton.addTarget(self, action: #selector(friendActionButtonTapped), for: .touchUpInside)
        contentView.addSubview(friendActionButton)
        
        // 상태 레이블 초기화
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.textAlignment = .center
        contentView.addSubview(statusLabel)
    }
    
    private func setupLayout() {
        userProfileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.width.height.equalTo(60)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(20)
        }
        
        friendActionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(120)
            make.height.equalTo(30)
            
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
    }
    
    // MARK: - Configuration
    func configure(with user: User, viewModel: FriendsViewModel) {
        self.user = user
        self.friendsViewModel = viewModel
        userNameLabel.text = user.userName
        userProfileImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "defaultProfileImage"))
        friendActionButton.isHidden = false // 버튼을 항상 보이게 설정
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            friendActionButton.isHidden = true
            statusLabel.isHidden = true
            return
        }
        
        friendActionButton.addTarget(self, action: #selector(friendActionButtonTapped), for: .touchUpInside) // 버튼 액션 추가
        updateFriendshipStatusUI(user: user, currentUserID: currentUserID)
    }
    
    // MARK: - Functions
    private func updateFriendshipStatusUI(user: User, currentUserID: String) {
        print("currentUserID = " + currentUserID)
        if let userId = user.uid {
            friendsViewModel?.checkFriendshipStatus(forUser: userId) { status in
                DispatchQueue.main.async {
                    self.friendActionButton.isHidden = false
                    switch status {
                    case "요청 보냄":
                        self.friendActionButton.isHidden = true
                        self.statusLabel.text = "요청 보냄"
                        self.statusLabel.textColor = UIColor(hex: "#FF3A4A")
                        self.statusLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
                        self.statusLabel.isHidden = false
                        
                    case "요청 받음":
                        self.friendActionButton.isHidden = false
                        
                        self.friendActionButton.layer.borderColor = UIColor(hex: "#FF3A4A").cgColor
                        self.friendActionButton.layer.borderWidth = 1
                        self.friendActionButton.setTitle("수락", for: .normal)
                        self.friendActionButton.setTitleColor(UIColor(hex: "#FF3A4A"), for: .normal)
                        self.friendActionButton.titleLabel?.font = UIFont.pretendardRegular(ofSize: 14)
                        self.statusLabel.isHidden = true
                        
                    case "이미 친구입니다":
                        self.updateUIAsAlreadyFriends()
                        
                    default:
                        self.friendActionButton.isHidden = false
                        self.friendActionButton.setInstagram()
                        self.friendActionButton.setTitle("친구 요청", for: .normal)
                        self.friendActionButton.setTitleColor(.white, for: .normal)
                        self.friendActionButton.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 14)
                        self.statusLabel.isHidden = true
                    }
                }
            }
        } else {
            // user.uid가 nil인 경우에 대한 처리
            DispatchQueue.main.async {
                // 예: 사용자의 UID가 없을 때의 기본 UI 설정
                self.friendActionButton.isHidden = true
                self.statusLabel.text = "사용자 정보 불명"
                self.statusLabel.textColor = .gray
                self.statusLabel.font = UIFont.systemFont(ofSize: 14)
                self.statusLabel.isHidden = false
            }
        }
    }


    
    @objc private func friendActionButtonTapped() {
        guard let user = user, let currentUserID = Auth.auth().currentUser?.uid else {
            print("User information missing or error.")
            return
        }
        
        friendsViewModel?.checkFriendshipStatus(forUser: user.uid!) { status in
            DispatchQueue.main.async {
                switch status {
                case "요청 받음":
                    self.friendsViewModel?.acceptFriendRequest(fromUser: user.uid!, forUser: currentUserID) { success, error in
                        if success {
                            self.updateUIAsAlreadyFriends()
                        } else {
                            print("Failed to accept friend request: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                case "친구 추가":
                    self.friendsViewModel?.sendFriendRequest(toUser: user.uid!, fromUser: currentUserID) { success, error in
                        if success {
                            self.updateFriendshipStatusUI(user: user, currentUserID: currentUserID)
                        } else {
                            print("Failed to send friend request: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                default:
                    print("No action defined for this status.")
                }
            }
        }
    }
    
    private func updateUIAsAlreadyFriends() {
        DispatchQueue.main.async {
            self.friendActionButton.isHidden = true
            self.statusLabel.text = "이미 친구입니다"
            
            self.statusLabel.textColor = UIColor(hex: "FF3A4A")
            self.statusLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
            self.statusLabel.isHidden = false
        }
    }
    
}
    

