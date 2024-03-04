//
//  LockedCapsuleCell.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit

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
    lazy var dayBadge: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        return label
    }()
    lazy var registerPlace: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        return label
    }()
    lazy var registerDay: UILabel = {
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
    
    private func setupViews() {
        contentView.addSubview(registerImage)
        contentView.addSubview(dayBadge)
        contentView.addSubview(registerPlace)
        contentView.addSubview(registerDay)
        
        registerImage.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.width.equalTo(330) //
            make.height.equalTo(registerImage.snp.width).multipliedBy(1.0/2.0)
        }
        
        dayBadge.snp.makeConstraints { make in
            make.top.equalTo(registerImage.snp.bottom).offset(5)
            make.leading.equalTo(registerImage.snp.leading)
            make.width.equalTo(60)
            make.height.equalTo(25)
        }
        
        registerPlace.snp.makeConstraints { make in
            make.top.equalTo(registerImage.snp.bottom).offset(5)
            make.leading.equalTo(dayBadge.snp.trailing).offset(10)
            make.height.equalTo(70)
            make.width.equalTo(195)
        }
        
        registerDay.snp.makeConstraints { make in
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


