//
//  NewUserViewController.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 3/10/24.
//

import UIKit

//#Preview{
//    NewUserViewController()
//}

class NewUserViewController: UIViewController {
    
    let imageLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5) // 투명도를 0.5로 설정
        label.text = "😢"
        label.font = UIFont.boldSystemFont(ofSize: 200)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.textAlignment = .center
        return label
    }()
    
    let newLabel: UILabel = {
        let label = UILabel()
//        label.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.5)
        label.text = "아직 생성된 캡슐이 없습니다 😭\n첫번째 캡슐을 만들어 시간여행을 준비하세요!"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let addNewTCButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("새로운 타임캡슐 만들기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset =  CGSize(width: 0, height: 3)
        button.addTarget(NewUserViewController.self, action: #selector(addNewTC), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addNewTCButton.setInstagram()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        configureImageView()
    }
    
    private func configureImageView() {
        view.addSubview(imageLabel)
        imageLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(view.bounds.height / 7)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalToSuperview().multipliedBy(3.0/7.0)
        }
        
        view.addSubview(newLabel)
        newLabel.snp.makeConstraints { make in
            make.top.equalTo(imageLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalToSuperview().multipliedBy(0.5/7.0)
        }
        
        view.addSubview(addNewTCButton)
        addNewTCButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(newLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(2.3/3.0)
            make.height.equalTo(50)

        }
    }
    
    @objc private func addNewTC() {
        print("새 타임머신 만들기 클릭되었습니다")
        let addNewTC = LocationMapkitViewController()
        navigationController?.pushViewController(addNewTC, animated: true)
    }
}
// MARK: - SwiftUI Preview
import SwiftUI

struct Previewsa : PreviewProvider {
    static var previews: some View {
        NewUserViewController().toPreview()
    }
}
