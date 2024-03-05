import UIKit
import SnapKit
import SDWebImage
import FirebaseAuth

class SearchUserTableViewCell: UITableViewCell {
    var user : User?
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
        userNameLabel.text = user.username
        userProfileImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "defaultProfileImage"))
        
        // 현재 로그인한 사용자 ID를 가져옴
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            // 로그인한 사용자 ID를 가져올 수 없는 경우, 버튼과 레이블을 숨김
            friendActionButton.isHidden = true
            statusLabel.isHidden = true
            return
        }
        
        // 사용자의 친구 상태에 따라 UI 업데이트
        updateFriendshipStatusUI(user: user, currentUserID: currentUserID)
    }
    
    // MARK: - Functions
    func updateFriendshipStatusUI(user: User, currentUserID: String) {
        // UI 업데이트 로직
        friendsViewModel?.checkFriendshipStatus(forUser: user.uid) { status in
            DispatchQueue.main.async {
                switch status {
                    
                case "요청 보냄":
                    self.friendActionButton.isHidden = true
                    self.statusLabel.text = "Requested"
                    self.statusLabel.textColor = .systemGray
                    self.statusLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
                    self.statusLabel.isHidden = false
                    
                case "요청 받음":
                    self.friendActionButton.isHidden = false
                    self.friendActionButton.layer.borderColor = UIColor(hex: "#D53369").cgColor
                    self.friendActionButton.layer.borderWidth = 1
                    self.friendActionButton.setTitle("Accept", for: .normal)
                    self.friendActionButton.setTitleColor(UIColor(hex: "#D53369"), for: .normal)
                    self.friendActionButton.titleLabel?.font = UIFont.pretendardRegular(ofSize: 14)
                    self.statusLabel.isHidden = true
                    
                default:
                    self.friendActionButton.isHidden = false
                    self.friendActionButton.setBlurryBeach()
                    self.friendActionButton.setTitle("Friend Request", for: .normal)
                    self.friendActionButton.setTitleColor(.white, for: .normal)
                    self.friendActionButton.titleLabel?.font = UIFont.pretendardRegular(ofSize: 14)
                    self.statusLabel.isHidden = true
                }
            }
        }
    }
    
    private func updateUIAsAlreadyFriends() {
        DispatchQueue.main.async {
            self.friendActionButton.isHidden = true
            self.statusLabel.text = "Already friend"
            self.statusLabel.textColor = UIColor(hex: "D15E6B")
            self.statusLabel.font = UIFont.pretendardSemiBold(ofSize: 14)
            self.statusLabel.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func friendActionButtonTapped() {
        guard let user = user, let currentUserID = Auth.auth().currentUser?.uid else {
            print("사용자 정보 누락 또는 에러입니다.")
            return
        }
        
        // 친구 상태 확인
        friendsViewModel?.checkFriendshipStatus(forUser: user.uid) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case "요청 받음":
                    // 친구 요청 수락 로직 실행
                    self?.friendsViewModel?.acceptFriendRequest(fromUser: user.uid, forUser: currentUserID) { success, error in
                        if success {
                            // 친구 요청 수락 성공 시, UI를 "Already friend"로 업데이트
                            self?.updateUIAsAlreadyFriends()
                        } else {
                            // 에러 처리
                            print("친구 요청 수락 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                        }
                    }
                case "친구 추가":
                    // 친구 요청 보내기 로직 실행
                    self?.friendsViewModel?.sendFriendRequest(toUser: user.uid, fromUser: currentUserID) { success, error in
                        if success {
                            // 요청 보내기 성공 시, UI 즉시 업데이트
                            self?.updateFriendshipStatusUI(user: user, currentUserID: currentUserID)
                        } else {
                            // 에러 처리
                            print("친구 요청 보내기 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                        }
                    }
                default:
                    print("현재 상태에서는 액션이 정의되지 않았습니다.")
                }
            }
        }
    }
}

