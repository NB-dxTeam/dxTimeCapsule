import UIKit
import SnapKit
import SDWebImage

class FriendListTableViewCell: UITableViewCell {
    var user: User? {
        didSet {
            configure()
        }
    }
    
    var friendsViewModel: FriendsViewModel? // ViewModel 추가
    
    private var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "D15E6B")
        label.textAlignment = .center
        return label
    }()
    
    
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
        contentView.addSubview(userProfileImageView)
        contentView.addSubview(userNameLabel)
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
        
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
    }
    
    // MARK: - Configuration
    private func configure() {
        guard let user = user else { return }
        userNameLabel.text = user.username
        userProfileImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "defaultProfileImage"))
        
        // viewModel을 사용하는 추가 구성 로직이 필요할 경우 여기에 추가합니다.
        // 예를 들어, 사용자의 친구 상태를 확인하고 statusLabel을 업데이트할 수 있습니다.
    }
}
