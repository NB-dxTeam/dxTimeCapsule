//
//  LaunchViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0051 on 2/23/24.
//

import UIKit
import SnapKit

class LaunchViewController: UIViewController {
    
    private lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        imageView.image = UIImage(named: "logo")
        
        return imageView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUI()
        setLayout()
    }
}

extension LaunchViewController {
    private func setUI() {
        view.backgroundColor = .systemBlue
        view.addSubview(logoImage)
    }
    
    private func setLayout() {
        logoImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }
}
