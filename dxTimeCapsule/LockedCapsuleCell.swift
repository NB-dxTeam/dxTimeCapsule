//
//  LockedCapsuleCell.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit
import SnapKit

class LockedCapsuleCell: UICollectionViewCell {
    static let identifier = "LockedCapsuleCell"
    lazy var registerImage: UIImageView = { // photoUrl
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
        label.font = UIFont.systemFont(ofSize: 18)
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
    
    func configure(with timeCapsule: TimeCapsules) {
        if let imageUrl = URL(string: timeCapsule.photoUrl), let imageData = try? Data(contentsOf: imageUrl) {
                self.registerImage.image = UIImage(data: imageData)
            } else {
                self.registerImage.image = UIImage(named: "placeholder")
            }

        // Directly use openDate and creationDate since they are non-optional
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: timeCapsule.creationDate, to: timeCapsule.openDate)
        if let days = components.day {
            self.dDay.text = "D-\(days)"
        }
        
        // Since userLocation is non-optional
        self.userLocation.text = timeCapsule.userLocation
        
        // Format creationDate directly
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Use your desired date format
        let dateStr = dateFormatter.string(from: timeCapsule.creationDate)
        self.creationDate.text = dateStr
    }
    
    private func setupViews() {
        contentView.addSubview(registerImage)
        contentView.addSubview(dDay)
        contentView.addSubview(userLocation)
        contentView.addSubview(creationDate)
        
        registerImage.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.width.equalTo(330) //
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
            make.leading.equalTo(dDay.snp.trailing).offset(10)
            make.height.equalTo(70)
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
        self.layer.cornerRadius = 30.0 // 모서리 설정
    }
}


