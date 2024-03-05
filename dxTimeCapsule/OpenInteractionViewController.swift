//
//  OpenInteractionViewController.swift
//  dxTimeCapsule
//
//  Created by 김우경 on 2/28/24.
//

import UIKit
import SnapKit
import CoreMotion

class OpenInteractionViewController: UIViewController {
    private let openImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "OpenTimeCapsule") 
        return imageView
    }()
    
    private let interactionGaugeView: UIView = UIView()
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "화면이 차오를 때까지 스마트폰을 흔들어주세요!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private var progressLayer: CAShapeLayer!
    private var motionManager: CMMotionManager!
    private var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupGaugeView()
        setupMotionManager()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if progressLayer == nil {
            setupGaugeView()
        }
    }
    
    private func setupLayout() {
        view.addSubview(openImageView)
        openImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        view.addSubview(interactionGaugeView)
        interactionGaugeView.snp.makeConstraints { make in
            make.center.equalTo(openImageView.snp.center)
            make.width.height.equalTo(220) // 중앙 이미지보다 약간 큰 크기로 설정
        }
        
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(openImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
    }
    
    private func setupGaugeView() {
        view.layoutIfNeeded()
        let centerPoint = CGPoint(x: interactionGaugeView.bounds.midX, y: interactionGaugeView.bounds.midY)
        let radius = interactionGaugeView.bounds.width / 2 - 10 // 10은 여백을 주기 위함입니다.
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)

        // 배경 게이지 설정
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor // 배경 게이지 색상
        backgroundLayer.lineWidth = 5 // 배경 게이지 굵기
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeEnd = 1
        interactionGaugeView.layer.addSublayer(backgroundLayer)

        // 진행 게이지 설정
        progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = UIColor.blue.cgColor // 진행 게이지 색상
        progressLayer.lineWidth = 7 // 진행 게이지 굵기
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0.2 // 초기값은 0으로, 진행 상황에 따라 변경됩니다.
        interactionGaugeView.layer.addSublayer(progressLayer)
    }
    
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            let threshold: Double = 0.5
            if abs(data.acceleration.x) > threshold || abs(data.acceleration.y) > threshold || abs(data.acceleration.z) > threshold {
                // progress 값을 증가시킵니다. 올바른 증가 방식으로 수정됨.
                let newProgress = min(self.progress + 0.1, 1)
                self.progress = newProgress
            }
        }
    }
}

