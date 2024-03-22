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
    
    // MARK: - Properties
    static let identifier = "LockedCapsuleCell"
    lazy var registerImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        return image
    }()
    lazy var dDay: UILabel = { // openDate - creationDate = D-Day
        let label = UILabel()
        label.backgroundColor = .systemBlue
        label.font = UIFont.boldSystemFont(ofSize: 44)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    lazy var addressTitle: UILabel = { // userLocation
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 60)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        return label
    }()
    lazy var creationDate: UILabel = { // creationDate
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 44)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initialization
    
    // 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()

    }
    
    // MARK: - Configuration
    
    // 셀을 구성하는 메서드
    func configure(with timeboxes: TimeBox) {
        // 이미지 URL을 사용하여 이미지를 로드하고 설정
        if let thumbnailURL = timeboxes.thumbnailURL, let url = URL(string: thumbnailURL) {
            // 이미지 로딩 라이브러리를 사용한 비동기 이미지 로딩
            self.registerImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            self.registerImage.image = UIImage(named: "placeholder")
        }

        // 오늘 날짜와 openDate 사이의 일수를 계산하여 D-Day를 결정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // UTC+9:00

        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: today, to: timeboxes.openTimeBoxDate!.dateValue())

        if let daysUntilOpening = components.day {
            // 날짜 차이에 따라 D-Day 표시를 조정
            let dDayPrefix = daysUntilOpening < 0 ? "D+" : "D-"
            self.dDay.text = "\(dDayPrefix)\(abs(daysUntilOpening))"
            
            // 배경색 설정 로직 추가
            if dDayPrefix == "D+" {
                self.dDay.backgroundColor = .gray // "D+" 일 때 회색으로 설정
            } else if dDayPrefix == "D-" {
                self.dDay.backgroundColor = UIColor(hex: "#C82D6B") // "D-"일 때 빨간색으로 설정
            }
        }

        // 사용자 위치를 설정
        self.addressTitle.text = timeboxes.addressTitle ?? "Unknown addressTitle"

        // 생성 날짜를 포맷에 맞게 설정
        dateFormatter.dateFormat = "yyyy-MM-dd" // 시간 부분은 제외하고 날짜만 표시
        let dateStr = dateFormatter.string(from: timeboxes.createTimeBoxDate!.dateValue())
        self.creationDate.text = dateStr
    }
    
    private func setupViews() {
        contentView.addSubview(registerImage)
        contentView.addSubview(dDay)
        contentView.addSubview(addressTitle)
        contentView.addSubview(creationDate)
        
        registerImage.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.15/16.0)
            make.top.equalToSuperview().inset(offset)
            make.height.equalTo(registerImage.snp.width).multipliedBy(9.0/16.0)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        dDay.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.3/16.0)
            let offset2 = UIScreen.main.bounds.height * (0.35/16.0)
            make.top.equalTo(registerImage.snp.bottom).offset(offset1)
            make.bottom.equalTo(addressTitle.snp.bottom)
            make.leading.equalToSuperview().inset(30)
            make.width.equalTo(registerImage.snp.width).multipliedBy(0.17/1.0)
            make.height.equalTo(offset2)
        }
        
        addressTitle.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.3/16.0)
            let offset2 = UIScreen.main.bounds.width * (0.10/2.0)
            make.top.equalTo(registerImage.snp.bottom).offset(offset1)
            make.leading.equalTo(dDay.snp.trailing).offset(offset2)
            make.height.equalToSuperview().multipliedBy(1.3/16.0)
            make.trailing.equalTo(creationDate.snp.leading)
        }
        
        creationDate.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.35/16.0)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(offset)
            make.width.equalTo(registerImage.snp.width).multipliedBy(0.26/1.0)
            make.bottom.equalTo(addressTitle.snp.bottom)
        }
        
    }
}


import SwiftUI
struct Preview: PreviewProvider {
    static var previews: some View {
        CustomModal().toPreview()
    }
}
