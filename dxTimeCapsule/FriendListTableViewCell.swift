import UIKit
import SnapKit
import SDWebImage

class FriendListTableViewCell: UITableViewCell {
    var user: User? {
        didSet {
            configure(with: user)
        }
    }
    
    var userProfileImageView: UIImageView!
    var userNameLabel: UILabel!
    var statusLabel: UILabel!
    
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
        contentView.addSubview(userProfileImageView)
        
        userNameLabel = UILabel()
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        contentView.addSubview(userNameLabel)
        
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(hex: "D15E6B")
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
        
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
    }
    
    // MARK: - Configuration
    func configure(with user: User?) {
        guard let user = user else { return }
        userNameLabel.text = user.username
        userProfileImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "placeholder"))
        statusLabel.text = "Friend"
    }
}
