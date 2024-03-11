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
    
    var imageView: UIImageView!
    var images: [UIImage] = []
    var currentImageIndex = 0
    
    let newLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 생성된 캡슐이 없습니다 🥲\n첫번째 캡슐을 만들어 시간여행을 준비하세요!"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let addNewTCButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("새로운 타임캡슐 만들기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 213/255.0, green: 51/255.0, blue: 105/255.0, alpha: 1.0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .black)
        button.layer.cornerRadius = 10
        button.addTarget(NewUserViewController.self, action: #selector(addNewTC), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addNewTCButton.setCustom1()
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startSlideShow()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        configureImageView()
        loadImages()
    }
    
    private func configureImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(view.bounds.height / 7)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalToSuperview().multipliedBy(1.5/3.0)
        }
        
        view.addSubview(newLabel)
        newLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalToSuperview().multipliedBy(0.5/7.0)
        }
        
        view.addSubview(addNewTCButton)
        addNewTCButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(newLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(1.5/3.0)
            make.height.equalToSuperview().multipliedBy(0.5/7.0)
        }
    }
    
    private func loadImages() {
        images = [
            UIImage(named: "kuma1")!,
            UIImage(named: "kuma2")!,
            UIImage(named: "kuma3")!,
            UIImage(named: "kuma4")!,
            UIImage(named: "kuma5")!
        ]
    }
    
    private func startSlideShow() {
        if !images.isEmpty {
            UIView.transition(with: imageView,
                              duration: 3.0,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.imageView.image = self.images[self.currentImageIndex]
                              },
                              completion: { _ in
                                self.moveToNextImage()
                                self.startSlideShow()
                              })
        }
    }
    
    private func moveToNextImage() {
        currentImageIndex += 1
        if currentImageIndex == images.count {
            currentImageIndex = 0
        }
    }
    
    @objc private func addNewTC() {
        print("새 타임머신 만들기 클릭되었습니다")
        // 새로운 타임캡슐을 만들기 위한 코드 추가
    }
}
