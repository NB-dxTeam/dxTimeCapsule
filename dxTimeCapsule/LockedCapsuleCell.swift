//
//  LockedCapsuleCell.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit
import SnapKit
import FirebaseFirestoreInternal


class LockedCapsuleCell: UICollectionViewCell {
    static let identifier = "LockedCapsuleCell"
    lazy var registerImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        return image
    }()
    lazy var dDay: UILabel = { // openDate - creationDate = D-Day
        let label = UILabel()
        label.backgroundColor = .systemBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        return label
    }()
    lazy var userLocation: UILabel = { // userLocation
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.pretendardBold(ofSize: 24)
        label.numberOfLines = 2
        return label
    }()
    lazy var creationDate: UILabel = { // creationDate
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()

    }
    
    func configure(with capsuleInfo: CapsuleInfo) {
        // 이미지 URL을 사용하여 이미지를 로드하고 설정합니다.
        if let imageUrl = capsuleInfo.tcBoxImageURL, let url = URL(string: imageUrl) {
            // 이미지 로딩 라이브러리를 사용한 비동기 이미지 로딩
            self.registerImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            self.registerImage.image = UIImage(named: "placeholder")
        }

        // 오늘 날짜와 openDate 사이의 일수를 계산하여 D-Day를 결정합니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // UTC+9:00

        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: today, to: capsuleInfo.openTimeCapsuleDate)

        if let daysUntilOpening = components.day {
            // 날짜 차이에 따라 D-Day 표시를 조정합니다.
            let dDayPrefix = daysUntilOpening < 0 ? "D+" : "D-"
            self.dDay.text = "\(dDayPrefix)\(abs(daysUntilOpening))"
            
            // 배경색 설정 로직 추가
            if dDayPrefix == "D+" {
                self.dDay.backgroundColor = .gray // "D+" 일 때 회색으로 설정
            } else if dDayPrefix == "D-" {
                self.dDay.backgroundColor = UIColor(hex: "#C82D6B") // "D-"일 때 빨간색으로 설정
            }
        }

        // 사용자 위치를 설정합니다.
        self.userLocation.text = capsuleInfo.userLocation ?? "Unknown location"

        // 생성 날짜를 포맷에 맞게 설정합니다.
        dateFormatter.dateFormat = "yyyy-MM-dd" // 시간 부분은 제외하고 날짜만 표시합니다.
        let dateStr = dateFormatter.string(from: capsuleInfo.createTimeCapsuleDate)
        self.creationDate.text = dateStr
    }
    
    private func setupViews() {
        contentView.addSubview(registerImage)
        contentView.addSubview(dDay)
        contentView.addSubview(userLocation)
        contentView.addSubview(creationDate)
        
        registerImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(registerImage.snp.width).multipliedBy(1.0/2.0)
        }
        
        dDay.snp.makeConstraints { make in
            make.top.equalTo(registerImage.snp.bottom).offset(5)
            make.leading.equalTo(registerImage.snp.leading)
            make.width.equalTo(60)
            make.height.equalTo(25)
        }
        
        userLocation.snp.makeConstraints { make in
            make.top.equalTo(registerImage.snp.bottom).offset(5)
            make.leading.equalTo(dDay.snp.trailing).offset(30)
            make.height.equalTo(30)
            make.width.equalTo(190)
        }
        
        creationDate.snp.makeConstraints { make in
            make.trailing.equalTo(registerImage.snp.trailing)
            make.bottom.lessThanOrEqualToSuperview().inset(15)
        }
        
        contentView.backgroundColor = .white
        //layer.cornerRadius = 30
        layer.masksToBounds = true
        
        //self.layer.borderWidth =  // 테두리 두께
        self.layer.borderColor = UIColor.gray.cgColor// 테두리 색상
        self.layer.cornerRadius = 10.0 // 모서리 설정
    }
}


