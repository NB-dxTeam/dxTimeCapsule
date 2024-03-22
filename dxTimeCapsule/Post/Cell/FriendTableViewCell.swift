//
//  FriendTableViewCell.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/22/24.
//

import UIKit
import Kingfisher

class FriendTableViewCell: UITableViewCell {
    
    static let identifier = "FriendTableViewCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25 // 이미지뷰 크기의 절반으로 설정하여 원형으로 만듭니다.
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    // CustomTableViewCell에 프로필 이미지와 이름 설정을 위한 메서드 추가
    public func configure(with friend: User) {
        print("Configuring cell with friend: \(friend)")
        nameLabel.text = friend.userName
        if let urlString = friend.profileImageUrl, let url = URL(string: urlString) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }

    
    // 서브뷰들을 셀에 추가하고 AutoLayout 설정
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let profileImageViewConstraints = [
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let nameLabelConstraints = [
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(profileImageViewConstraints)
        NSLayoutConstraint.activate(nameLabelConstraints)
    }
    
    // 셀이 재사용될 때 기존의 이미지 로딩 작업을 취소하고 라벨을 초기화하는 메서드
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.kf.cancelDownloadTask()
        nameLabel.text = nil
        profileImageView.image = nil
    }
}
