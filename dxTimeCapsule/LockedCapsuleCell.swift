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
    // D-Day 정보를 표시하는 레이블
    lazy var dDayBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 11
        view.clipsToBounds = true
        return view
    }()
    
    // D-Day 정보를 표시하는 레이블
    lazy var dDayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    lazy var addressTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 60)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        return label
    }()
    lazy var creationDate: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 44)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initialization
    
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
    func configure(with timeBox: TimeBox, dDayColor: UIColor) {
        // 이미지 설정
        if let imageUrl = timeBox.thumbnailURL ?? timeBox.imageURL?.first, let url = URL(string: imageUrl) {
            self.registerImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            self.registerImage.image = UIImage(named: "placeholder")
        }
        
        // D-Day 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대 설정
        
        let today = Date()
        let calendar = Calendar.current
        
        if let openTimeBoxDate = timeBox.openTimeBoxDate?.dateValue() {
            let components = calendar.dateComponents([.day], from: today, to: openTimeBoxDate)
            
            if let daysUntilOpening = components.day {
                if daysUntilOpening == 0 {
                    
                    // (수정) 오늘이 개봉일일 때 "D-day" 반환
                    self.dDayLabel.text = "D-day"
                } else {
                    let dDayPrefix = daysUntilOpening < 0 ? "D+" : "D-"
                    self.dDayLabel.text = "\(dDayPrefix)\(abs(daysUntilOpening))"
                }
                self.dDayBackgroundView.backgroundColor = dDayColor
            }
        }

        // 사용자 위치 설정
        self.addressTitle.text = timeBox.addressTitle ?? "Unknown location"
        
        // 생성 날짜 설정
        if let createTimeBoxDate = timeBox.createTimeBoxDate?.dateValue() {
            let dateStr = dateFormatter.string(from: createTimeBoxDate)
            self.creationDate.text = dateStr
        }
    }
    
    private func setupViews() {
        contentView.addSubview(registerImage)
        contentView.addSubview(dDayBackgroundView)
        contentView.addSubview(addressTitle)
        contentView.addSubview(creationDate)
        
        registerImage.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.15/16.0)
            make.top.equalToSuperview().inset(offset)
            make.height.equalTo(registerImage.snp.width).multipliedBy(9.0/16.0)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        dDayBackgroundView.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.3/16.0)
            let offset2 = UIScreen.main.bounds.height * (0.35/16.0)
            make.top.equalTo(registerImage.snp.bottom).offset(offset1)
            make.bottom.equalTo(addressTitle.snp.bottom)
            make.leading.equalToSuperview().inset(30)
            make.width.equalTo(registerImage.snp.width).multipliedBy(0.17/1.0)
            make.height.equalTo(offset2)
        }
        dDayBackgroundView.addSubview(dDayLabel)
        
        // dDayLabel의 레이아웃을 dDayBackgroundView 내부 중앙에 맞춤
        dDayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)) // 여백 조정
        }
        
        addressTitle.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (0.3/16.0)
            let offset2 = UIScreen.main.bounds.width * (0.10/2.0)
            make.top.equalTo(registerImage.snp.bottom).offset(offset1)
            make.leading.equalTo(dDayBackgroundView.snp.trailing).offset(offset2)
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
        TimeBoxListViewController().toPreview()
    }
}
