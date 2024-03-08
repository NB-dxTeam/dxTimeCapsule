//
//  OpenInteractionViewController.swift
//  dxTimeCapsule
//  Created by 김우경 on 2/28/24.
//


import UIKit
import SnapKit
import CoreMotion

class OpenInteractionViewController: UIViewController {
    var documentId: String?

    // 중앙에 표시될 이미지 뷰를 정의합니다. Lazy loading을 사용하여 필요할 때 생성되도록 합니다.
    private let openImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "OpenTimeCapsule")
        return imageView
    }()
    
    // 인터랙션 게이지 뷰 이 뷰 위에 게이지가 그려집니다.
    private let interactionGaugeView: UIView = UIView()
    
    // 사용자 안내 텍스트
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "화면이 차오를 때까지 스마트폰을 흔들어주세요!"
        label.textAlignment = .center
        label.numberOfLines = 0 // 여러 줄로 표시할 수 있도록 합니다.
        label.font = UIFont.systemFont(ofSize: 16) //
        label.textColor = .darkGray
        return label
    }()
  
    private var skipButton: UIButton!
    private var progressLayer: CAShapeLayer!
    private var motionManager: CMMotionManager!
    private var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress // 게이지의 진행 상황 업데이트
            //게이지가 꽉 찼을 때 새 뷰 컨트롤러로 전환
             if progress >= 1 {
                 DispatchQueue.main.async { [weak self] in
                     self?.navigateToOpenCapsuleViewController()
                 }
             }
         }
     }
    
    // OpenCapsuleViewController로 네비게이션하는 메소드
    private func navigateToOpenCapsuleViewController() {
        let openCapsuleVC = OpenCapsuleViewController()
        openCapsuleVC.documentId = documentId // documentId 전달
        openCapsuleVC.modalPresentationStyle = .fullScreen // 전체 화면
        present(openCapsuleVC, animated: true, completion: nil) // 모달
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupGaugeView()
        setupMotionManager()
        setupSkipButton()
    }
    
    // 뷰의 레이아웃이 변경될 때마다 호출됩니다. 여기서 게이지 뷰를 다시 설정할 수 있습니다.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if progressLayer == nil {
            setupGaugeView()
        }
    }
    
    private func setupLayout() {
        // 이미지 뷰
        view.addSubview(openImageView)
        openImageView.snp.makeConstraints { make in
            make.center.equalToSuperview() // 화면 중앙
            make.width.height.equalTo(200) // 너비와 높이 200
        }
        
        // 게이지 뷰
        view.addSubview(interactionGaugeView)
        interactionGaugeView.snp.makeConstraints { make in
            make.center.equalTo(openImageView.snp.center) // 이미지 뷰의 중앙
            make.width.height.equalTo(220) // 이미지 뷰보다 약간 큰 크기
        }
        
        // 안내 텍스트 레이블
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(openImageView.snp.bottom).offset(20) // 이미지 뷰 아래
            make.left.right.equalToSuperview().inset(20) // 좌우 여백을 20
        }
    }
    
    // 스킵 버튼 설정
    private func setupSkipButton() {
        skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        
        skipButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-220)
        }
    }

    // 스킵 버튼 탭
    @objc private func skipButtonTapped() {
        navigateToOpenCapsuleViewController()
    }
    
    // 게이지 뷰 설정
    private func setupGaugeView() {
        view.layoutIfNeeded()
        // 게이지를 그릴 위치와 크기를 계산
        let centerPoint = CGPoint(x: interactionGaugeView.bounds.midX, y: interactionGaugeView.bounds.midY)
        let radius = interactionGaugeView.bounds.width / 2 - 10 // 여백을 고려한 반지름을 계산
        // 게이지를 그리기 위한 경로 생성
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)
        
        // 배경 게이지를 설정
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor // 색상
        backgroundLayer.lineWidth = 5 // 선의 굵기
        backgroundLayer.fillColor = UIColor.clear.cgColor // 내부를 채우지 않습니다.
        backgroundLayer.strokeEnd = 1 // 전체를 그립니다.
        interactionGaugeView.layer.addSublayer(backgroundLayer) // 레이어를 추가합니다.
        
        // 진행 게이지를 설정합니다.
        progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = UIColor.blue.cgColor // 색상
        progressLayer.lineWidth = 7 // 선의 굵기
        progressLayer.fillColor = UIColor.clear.cgColor // 내부를 채우지 않습니다.
        progressLayer.strokeEnd = 0 // 초기값
        interactionGaugeView.layer.addSublayer(progressLayer) // 레이어를 추가합니다.
    }
    
    // 모션 매니저를 설정하고 가속도계 업데이트를 시작하는 메소드입니다.
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1 // 업데이트 간격을 설정합니다.
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            // 가속도계 데이터를 받아 처리합니다.
            guard let self = self, let data = data else { return }
            // 설정한 임계값을 초과하는 가속도를 감지하면 진행률을 업데이트합니다.
            let threshold: Double = 0.5
            if abs(data.acceleration.x) > threshold || abs(data.acceleration.y) > threshold || abs(data.acceleration.z) > threshold {
                let newProgress = min(self.progress + 0.1, 1) // 진행률을 증가시킵니다.
                self.progress = newProgress // 진행 상황에 따라 게이지를 업데이트합니다.
            }
        }
    }
    // 실기기 연결 하지않을때 시뮬레이터에서 테스트할 수 있는 쉐이크 모션 메소드 메소드
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Shake 이벤트가 발생했을 때 실행할 로직입니다.
            // 예: progress 값을 조금씩 증가시키고, 이를 통해 게이지를 업데이트합니다.
            let newProgress = min(self.progress + 0.1, 1)
            self.progress = newProgress
        }
    }
}


