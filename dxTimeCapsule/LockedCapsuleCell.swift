//
//  LockedCapsuleCell.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit

class LockedCapsuleCell: UICollectionViewCell {
    static let identifier = "LockedCapsuleCell"
    lazy var registerImage: UIImage = {
        let image = UIImage()
        return image
    }()
    lazy var dayBadge: UILabel = {
        let label = UILabel()
        return label
    }()
    lazy var registerPlace: UILabel = {
        let label = UILabel()
        return label
    }()
    lazy var registerDay: UILabel = {
        let label = UILabel()
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
}
