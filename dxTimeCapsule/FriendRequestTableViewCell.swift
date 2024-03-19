import UIKit
import SnapKit
//import SDWebImage
import FirebaseAuth

class FriendRequestTableViewCell: UITableViewCell {
    var user: User?
    var friendsViewModel: FriendsViewModel?
    var acceptFriendRequestAction: (() -> Void)?

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardRegular(ofSize: 20)
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("친구 수락", for: .normal)
        button.layer.borderColor = UIColor(hex: "#FF3A4A").cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(UIColor(hex: "#FF3A4A"), for: .normal)
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 14)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Now friend"
        label.font = UIFont.pretendardSemiBold(ofSize: 14)
        label.textColor = UIColor(hex: "C82D6B")
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(userProfileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(statusLabel)
        
        userProfileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.width.height.equalTo(60)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(20)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(acceptButton.snp.centerY)
            make.trailing.equalTo(acceptButton.snp.trailing)
            make.width.equalTo(acceptButton.snp.width)
            make.height.equalTo(acceptButton.snp.height)
        }
        
        acceptButton.addTarget(self, action: #selector(acceptFriendRequest), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with user: User, viewModel: FriendsViewModel) {
        self.user = user
        self.friendsViewModel = viewModel
        userNameLabel.text = user.userName
        userProfileImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "defaultProfileImage"))
        acceptButton.isHidden = false // 버튼을 항상 보이게 설정

        guard let currentUserID = Auth.auth().currentUser?.uid else {
            acceptButton.isHidden = true
            statusLabel.isHidden = true
            return
        }
        
        acceptButton.addTarget(self, action: #selector(acceptFriendRequest), for: .touchUpInside) // 버튼 액션 추가
        updateFriendshipStatusUI(user: user, currentUserID: currentUserID)
    }
    
    
    // MARK: - Functions
    private func updateFriendshipStatusUI(user: User, currentUserID: String) {
        friendsViewModel?.checkFriendshipStatus(forUser: user.uid!) { status in
            DispatchQueue.main.async {
                self.acceptButton.isHidden = false
                switch status {
                case "요청 받음":
                    self.acceptButton.isHidden = false
                    self.statusLabel.isHidden = true
                    
                case "이미 친구입니다":
                    self.updateUIAsAlreadyFriends()
                    
                default:
                    self.acceptButton.isHidden = false
                    self.statusLabel.isHidden = true
                }
            }
        }
    }
    
    private func updateUIAsAlreadyFriends() {
        DispatchQueue.main.async {
            self.acceptButton.isHidden = true
            self.statusLabel.isHidden = false
        }
    }
    
    @objc private func acceptFriendRequest() {
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

                default:
                    print("No action defined for this status.")
                }
            }
        }
    }

}
