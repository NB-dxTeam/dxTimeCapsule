//
//  OpenedTCCollectionViewCell.swift
//  dxTimeCapsule
//
//  Created by t2023-m0028 on 2/24/24.
//

import UIKit

class OpenedTCCollectionViewCell: UICollectionViewCell {
   
       // 셀에 표시할 이미지 뷰
       let imageView: UIImageView = {
           let imageView = UIImageView()
           imageView.translatesAutoresizingMaskIntoConstraints = false
           imageView.contentMode = .scaleAspectFit
           return imageView
       }()
       
       // 셀을 초기화하고 서브뷰를 추가하는 메서드
       override init(frame: CGRect) {
           super.init(frame: frame)
           
           // 이미지 뷰 추가
            addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
           // 모서리를 둥글게 처리
           layer.cornerRadius = 10
           layer.masksToBounds = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // 셀에 이미지를 설정하는 메서드
        func setImage(_ image: UIImage) {
            imageView.image = image
        }
    }
