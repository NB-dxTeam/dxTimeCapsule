//
//  NotificationTableViewCell.swift
//  dxTimeCapsule
//
//  Created by t2023-m0028 on 2/29/24.
//

import UIKit
import SnapKit

class NotificationTableViewCell: UITableViewCell {

    let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25 // 반지름 설정 (정사각형의 절반)
        imageView.layer.masksToBounds = true // 이미지 뷰의 외부를 벗어나는 부분 잘라내기
        return imageView
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(cellImageView)
        addSubview(contentLabel)
          
        cellImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(cellImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
