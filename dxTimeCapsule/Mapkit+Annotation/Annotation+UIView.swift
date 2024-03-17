//
//  Annotation+UIView.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/13/24.
//

import UIKit
import SnapKit

class CustomCalloutView: UIView {
    
    // MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        // 여기에 더 많은 스타일 설정이 있을 수 있습니다.
        return imageView
    }()
    
    private let friendsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.numberOfLines = 0
        // 여기에 더 많은 스타일 설정이 있을 수 있습니다.
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .proximaNovaRegular(ofSize: 14)
        label.numberOfLines = 2
        // 여기에 더 많은 스타일 설정이 있을 수 있습니다.
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Add subviews 하위 뷰 추가
        [profileImageView, friendsLabel, dateLabel].forEach { addSubview($0) }
        
        // Set up constraints 제약조건 설정
        setupCalloutViewSize()
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().inset(8)
            make.width.height.equalTo(30) // 프로필 이미지의 크기 설정
        }
        friendsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
            // 상위 뷰의 전체 높이에 대한 2/3 위치에 friendsLabel을 둡니다.
            make.bottom.equalToSuperview().multipliedBy(2.0/3.0)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    // CustomCalloutView 크기 설정
    private func setupCalloutViewSize() {
        self.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
    }
    // MARK: - Configuration
    func configure(with timeBox: TimeBox, friends: [Friend]?) {
        // 프로필 이미지 설정
        if let firstFriend = friends?.first, let profileImageUrl = URL(string: firstFriend.profileImageUrl ?? "") {
            profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: UIImage(named: "placeholder"))
        } else {
            profileImageView.image = UIImage(named: "placeholder")
        }
        
        // 친구 이름을 라벨에 표시
        if let friends = friends, !friends.isEmpty {
            friendsLabel.text = friends.map { $0.name }.joined(separator: ", ")
        } else {
            friendsLabel.text = "친구 없음"
        }
        
        // 날짜 포맷팅
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd(E)"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.locale = Locale(identifier: "ko_KR")
        // TimeBox 구조체의 createTimeBoxDate 프로퍼티를 사용하여 생성일을 표시합니다.
        dateLabel.text = "타임캡슐 생성일: \n \(dateFormatter.string(from: timeBox.createTimeBoxDate.dateValue()))"
    }
}
