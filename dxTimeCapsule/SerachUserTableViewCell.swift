import UIKit
import SnapKit
import SDWebImage

class SearchUserTableViewCell: UITableViewCell {
    var actionButton: UIButton! // 친구 추가 또는 요청 수락 버튼
    var userProfileImageView: UIImageView!
    var nicknameLabel: UILabel!
    
    var addUserAction: (() -> Void)? // 추가할 속성

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        userProfileImageView = UIImageView()
        userProfileImageView.contentMode = .scaleAspectFill // 이미지 콘텐츠 모드 설정
        userProfileImageView.layer.cornerRadius = 25
        userProfileImageView.clipsToBounds = true
        addSubview(userProfileImageView)
        
        nicknameLabel = UILabel()
        nicknameLabel.font = UIFont.boldSystemFont(ofSize: 25) // 닉네임 폰트를 볼드체로 설정
        addSubview(nicknameLabel)
        
        // 친구 추가 또는 요청 수락 버튼 설정
        actionButton = UIButton(type: .system)
        actionButton.setTitle("친구 요청", for: .normal)
        actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 15 // 버튼 모서리를 둥글게 처리
        actionButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0) // 버튼 배경색 설정
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        addSubview(actionButton)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        userProfileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview() // 상하 중앙 정렬
            make.leading.equalToSuperview().offset(16) // 왼쪽 여백 설정
            make.width.height.equalTo(80) // 이미지뷰 크기 설정
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview() // 상하 중앙 정렬
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(16) // 이미지 오른쪽에 붙이고 여백 추가
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview() // 상하 중앙 정렬
            make.trailing.equalToSuperview().offset(-16) // 오른쪽 여백 설정
            make.width.equalTo(100) // 버튼 너비 설정
            make.height.equalTo(30) // 버튼 높이 설정
        }
    }
    
    // MARK: - Action
    @objc private func actionButtonTapped() {
        addUserAction?() // 친구 추가/수락 버튼 클릭 시 액션 실행
    }
    
    // MARK: - Configuration
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

