import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {
    var addUserButton: UIButton!
    var userProfileImageView: UIImageView!
    var nicknameLabel: UILabel!
    
    var addUserAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        userProfileImageView = UIImageView()
        userProfileImageView.layer.cornerRadius = 25
        userProfileImageView.clipsToBounds = true
        addSubview(userProfileImageView)
        
        nicknameLabel = UILabel()
        addSubview(nicknameLabel)
        
        addUserButton = UIButton(type: .system)
        addUserButton.setTitle("친구 추가", for: .normal)
        addUserButton.addTarget(self, action: #selector(addUserButtonTapped), for: .touchUpInside)
        addSubview(addUserButton)
        
        // 프로필 이미지 뷰 레이아웃 설정
        userProfileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.left.equalTo(userProfileImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        addUserButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func addUserButtonTapped() {
        addUserAction?()
    }
    
    func configure(with user: User) {
        nicknameLabel.text = user.nickname
        nicknameLabel.textColor = .black
        
        // 프로필 이미지 URL이 nil이거나 비어있는 경우 기본 이미지 사용
        if let profileImageUrl = user.profileImageUrl, !profileImageUrl.isEmpty {
            userProfileImageView.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(named: "defaultProfileImage"))
        } else {
            // 기본 이미지 설정
            userProfileImageView.image = UIImage(named: "defaultProfileImage")
        }
    }
}
