import UIKit
import SnapKit
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class FriendRequestTableViewCell: UITableViewCell {
    let db = Firestore.firestore()
    
    var user: User?
    var acceptRequestButtonTapped: (() -> Void)?
    //var declineRequestButtonTapped: (() -> Void)? // 나중에 구현
    
    var userProfileImageView: UIImageView!
    var userNameLabel: UILabel!
    var acceptButton: UIButton!
    //var declineButton: UIButton! // 나중에 구현
    var statusLabel: UILabel! // 상태를 나타내는 레이블
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        acceptButton.setBlurryBeach() // 버튼의 스타일을 설정함
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        userProfileImageView = UIImageView()
        userProfileImageView.layer.cornerRadius = 25
        userProfileImageView.clipsToBounds = true
        contentView.addSubview(userProfileImageView)
        
        userNameLabel = UILabel()
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        contentView.addSubview(userNameLabel)
        
        acceptButton = UIButton(type: .system)
        acceptButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        acceptButton.layer.cornerRadius = 10
        acceptButton.setTitle("Accept", for: .normal) // 버튼 텍스트 설정
        contentView.addSubview(acceptButton)
        
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(hex: "D15E6B")
        statusLabel.textAlignment = .center
        contentView.addSubview(statusLabel)
        
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
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
        
        acceptButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(120) // 버튼의 너비 설정
            make.height.equalTo(30)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
    }
    
    private func fetchUser(with userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists, error == nil else {
                completion(nil)
                return
            }
            
            let data = document.data()
            let user = User(
                uid: userId,
                email: data?["email"] as? String ?? "",
                username: data?["username"] as? String ?? "",
                profileImageUrl: data?["profileImageUrl"] as? String
            )
            completion(user)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with user: User) {
        self.user = user
        userNameLabel.text = user.username
        userProfileImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "placeholder"))
        acceptButton.isHidden = false
        statusLabel.isHidden = true
    }
    
    @objc private func acceptButtonTapped() {
        acceptRequestButtonTapped?()
    }
}
