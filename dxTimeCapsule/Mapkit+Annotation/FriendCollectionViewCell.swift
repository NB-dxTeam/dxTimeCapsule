//
//  FriendCollectionViewCell.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/19/24.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    private let profileImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 25
            return imageView
        }()
        
        private let usernameLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            addSubview(profileImageView)
            addSubview(usernameLabel)
            
            profileImageView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.centerX.equalToSuperview()
                make.width.equalTo(50)
                make.height.equalTo(50)
            }

            usernameLabel.snp.makeConstraints { make in
                make.top.equalTo(profileImageView.snp.bottom).offset(5)
                make.leading.equalToSuperview().offset(5)
                make.trailing.equalToSuperview().offset(-5)
                make.bottom.equalToSuperview().offset(-10)
            }
        }
        
        func configure(with friend: Friend) {
            usernameLabel.text = friend.username
            if let profileImageUrlString = friend.profileImageUrl, let profileImageUrl = URL(string: profileImageUrlString) {
                profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: UIImage(named: "defaultProfileImage"))
            } else {
                profileImageView.image = UIImage(named: "defaultProfileImage") // Use a default image if no URL is provided
            }
        }
}
