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
//    private let capsuleImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
//        // 여기에 더 많은 스타일 설정이 있을 수 있습니다.
//        return imageView
//    }()
    
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
        [friendsLabel, dateLabel].forEach { addSubview($0) }
        
        // Set up constraints 제약조건 설정
        setupCalloutViewSize()
        setupConstraints()
        
    }
    
    private func setupConstraints() {
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
    func configure(with capsuleInfo: CapsuleInfo) {
        // Assuming 'capsuleInfo.tcBoxImageURL' is a URL string to the image
//        if let imageURLString = capsuleInfo.tcBoxImageURL, let imageURL = URL(string: imageURLString) {
//            self.capsuleImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
//        } else {
//            self.capsuleImageView.image = UIImage(named: "placeholder")
//        }
        friendsLabel.text = capsuleInfo.friendID ?? "😄"
        
        // Date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd(E)"
        dateFormatter.timeZone = TimeZone(identifier: "Asiz/Seoul") // 한국 시간대
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateLabel.text = "타임캡슐 생성일: \n \(dateFormatter.string(from: capsuleInfo.createTimeCapsuleDate))"
    }
}
