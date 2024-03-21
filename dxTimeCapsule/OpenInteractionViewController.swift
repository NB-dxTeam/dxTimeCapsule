//
//  OpenInteractionViewController.swift
//  dxTimeCapsule
//  Created by 김우경 on 2/28/24.
//


import UIKit
import SnapKit
import CoreMotion
import FirebaseFirestore

class OpenInteractionViewController: UIViewController {
    var documentId: String?
    
    // 하늘색 정의
    let skyBlueColor = UIColor(red: 135/255.0, green: 206/255.0, blue: 235/255.0, alpha: 1.0)

    private var circlePath: UIBezierPath?
    
    // 중앙에 표시될 이미지 뷰를 정의합니다. Lazy loading을 사용하여 필요할 때 생성되도록 합니다.
    private let openImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "OpenTimeCapsule")
        return imageView
    }()
    
    // 인터랙션 게이지 뷰 이 뷰 위에 게이지가 그려집니다.
    private let interactionGaugeView: UIView = UIView()
    
    // 사용자 안내 텍스트 (버전 2)
    private func showFloatingMessage() {
        let labelContainer = UIView()
        labelContainer.backgroundColor = .systemGray5 // 여기서 회색 배경 설정
        view.addSubview(labelContainer)
        labelContainer.layer.cornerRadius = 16 // 둥근 모서리 적용
        labelContainer.clipsToBounds = true
        labelContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60) // 상단 safe area 아래로
            make.height.equalTo(48) // 컨테이너 높이 설정
            make.left.right.equalToSuperview().inset(46) // 좌우 여백 조정
        }
        
        let floatingLabel = UILabel()
        floatingLabel.text = "스마트폰을 흔들어 게이지를 채우세요!"
        floatingLabel.textColor = .darkGray
        floatingLabel.textAlignment = .center
        floatingLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy) // 더 굵은 폰트로 설정 .semibold, .heavy, .black
        floatingLabel.clipsToBounds = true
        labelContainer.addSubview(floatingLabel) // labelContainer 안에 floatingLabel을 추가
        floatingLabel.snp.makeConstraints { make in
               make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)) // 내부 여백을 통해 텍스트의 좌우 여백을 조정
           }

        // 둥둥 떠있는 애니메이션
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            labelContainer.transform = CGAffineTransform(translationX: 0, y: 10)
        }, completion: nil)

    }

    // 사용자 안내 텍스트
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = """
🎉 축하합니다! 🎉
당신이 남긴 소중한 추억을 만나볼 시간입니다.
"""
        label.textAlignment = .center
        label.numberOfLines = 0 // 여러 줄로 표시할 수 있도록 합니다.
        label.font = UIFont.systemFont(ofSize: 16) //
        label.textColor = .darkGray
        return label
    }()
  
    private var isNavigating = false
    private var skipButton: UIButton!
    private var progressLayer: CAShapeLayer!
    private var motionManager: CMMotionManager!
    private var progress: CGFloat = 0 {
        didSet {
            // 이전에는 progressLayer.strokeEnd = progress 로 직접 업데이트하였으나,
            // 이제는 updateProgress 메소드를 호출하여 그라디언트 프로그레스 레이어를 업데이트합니다.
            updateProgress(to: progress)
            if progress >= 1 && !isNavigating {
                isNavigating = true
                DispatchQueue.main.async { [weak self] in
                    self?.navigateToOpenCapsuleViewController()
                }
            }
        }
    }
    
    // OpenCapsuleViewController로 네비게이션하는 메소드
    private func navigateToOpenCapsuleViewController() {
        guard let docId = documentId else { return } // documentId가 nil이면 함수를 종료합니다.

        let db = Firestore.firestore() // Firestore 인스턴스를 가져옵니다.

        // 파이어베이스의 "timeCapsules" 컬렉션에서 documentId에 해당하는 문서를 찾아
        // isOpened 필드를 true로 업데이트합니다.
        db.collection("timeCapsules").document(docId).updateData([
            "isOpened": true
        ]) { error in
            if let error = error {
                // 문서 업데이트에 실패한 경우 에러를 콘솔에 출력합니다.
                print("Error updating document: \(error)")
            } else {
                // 문서 업데이트에 성공한 경우 콘솔에 성공 메시지를 출력하고,
                // OpenCapsuleViewController로 화면 전환을 준비합니다.
                print("Document successfully updated")
                DispatchQueue.main.async { [weak self] in
                    let openCapsuleVC = OpenCapsuleViewController()
                    openCapsuleVC.documentId = self?.documentId // documentId를 전달합니다.
                    openCapsuleVC.modalPresentationStyle = .fullScreen // 전체 화면 모달 스타일로 설정합니다.
                    self?.present(openCapsuleVC, animated: true, completion: nil) // 모달을 표시합니다.
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupGaugeView()
        setupMotionManager()
        setupSkipButton()
        setupGradientProgress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showFloatingMessage() // 이 페이지에 진입했을 때 안내 메시지를 보여줍니다.
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
            make.width.height.equalTo(220) // 너비와 높이 200
        }
        
        // 게이지 뷰
        view.addSubview(interactionGaugeView)
        interactionGaugeView.snp.makeConstraints { make in
            make.center.equalTo(openImageView.snp.center) // 이미지 뷰의 중앙
            make.width.height.equalTo(310) // 이미지 뷰보다 약간 큰 크기
        }
        
        // 안내 텍스트 레이블
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(interactionGaugeView.snp.bottom).offset(30) // 이미지 뷰 아래
            make.left.right.equalToSuperview().inset(20) // 좌우 여백을 20
        }
    }
    
    // 스킵 버튼 설정
    private func setupSkipButton() {
        skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.tintColor = UIColor(hex: "#1C9FFF")
        skipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17) // 버튼의 텍스트를 볼드로 설정
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        
        skipButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50) // 하단 safe area로부터 20포인트 위에 위치
            }
        }

    // 스킵 버튼 탭
    @objc private func skipButtonTapped() {
        if !isNavigating {
            isNavigating = true
            navigateToOpenCapsuleViewController()
        }
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
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor // 색상
        backgroundLayer.lineWidth = 9 // 선의 굵기
        backgroundLayer.fillColor = UIColor.clear.cgColor // 내부를 채우지 않습니다.
        backgroundLayer.strokeEnd = 1 // 전체를 그립니다.
        interactionGaugeView.layer.addSublayer(backgroundLayer) // 레이어를 추가합니다.
        
        // 진행 게이지를 설정합니다.
        progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        //progressLayer.strokeColor = skyBlueColor.cgColor // 진행 게이지의 색상을 하늘색으로 설정
       //progressLayer.strokeColor = UIColor.systemOrange.cgColor // 색상
        //progressLayer.strokeColor = UIColor(hex: "#C82D6B").cgColor // 색상
        progressLayer.lineWidth = 9 // 선의 굵기
        progressLayer.fillColor = UIColor.clear.cgColor // 내부를 채우지 않습니다.
        progressLayer.strokeEnd = 0 // 초기값
        interactionGaugeView.layer.addSublayer(progressLayer) // 레이어를 추가합니다.
    }
    
    private func setupGradientProgress() {
        view.layoutIfNeeded()
        // circlePath 설정
        let centerPoint = CGPoint(x: interactionGaugeView.bounds.midX, y: interactionGaugeView.bounds.midY)
        let radius = interactionGaugeView.bounds.width / 2 - 10
        circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)

        // 그라디언트 레이어 생성 및 설정
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = interactionGaugeView.bounds
        gradientLayer.colors = [
            UIColor(red: 66/255.0, green: 176/255.0, blue: 255/255.0, alpha: 1.0).cgColor, // #42B0FF
            UIColor(red: 198/255.0, green: 229/255.0, blue: 255/255.0, alpha: 1.0).cgColor // #C6E5FF
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        // 진행률을 표시할 CAShapeLayer 생성 및 설정
        let progressLayer = CAShapeLayer()
        progressLayer.path = circlePath?.cgPath
        progressLayer.lineWidth = 9
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.black.cgColor // 마스크로 사용되므로 실제 색상은 중요하지 않음
        progressLayer.strokeEnd = 0.0

        // 그라디언트 레이어에 마스크로 설정
        gradientLayer.mask = progressLayer

        // 그라디언트 레이어를 interactionGaugeView의 레이어에 추가
        interactionGaugeView.layer.addSublayer(gradientLayer)
    }

    // 게이지의 진행 상황을 업데이트하는 메소드
    func updateProgress(to progress: CGFloat) {
        DispatchQueue.main.async {
            guard let maskLayer = self.interactionGaugeView.layer.sublayers?.first(where: { $0 is CAGradientLayer })?.mask as? CAShapeLayer else { return }
            maskLayer.strokeEnd = progress
        }
    }

    // 모션 매니저를 설정하고 가속도계 업데이트를 시작하는 메소드
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1 // 업데이트 간격을 설정합니다.
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            // 가속도계 데이터를 받아 처리합니다.
            guard let self = self, let data = data else { return }
            // 설정한 임계값을 초과하는 가속도를 감지하면 진행률을 업데이트합니다.
            let threshold: Double = 1.5
            if abs(data.acceleration.x) > threshold || abs(data.acceleration.y) > threshold || abs(data.acceleration.z) > threshold {
                       let newProgress = min(self.progress + 0.1, 1) // 진행률을 증가시킵니다.
                       DispatchQueue.main.async {
                           self.updateProgress(to: newProgress) // 메인 스레드에서 UI 업데이트
                       }
            }
        }
    }
    // 실기기 연결 하지않을때 시뮬레이터에서 테스트할 수 있는 쉐이크 모션 메소드 메소드
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Shake 이벤트가 발생했을 때 실행할 로직
            // 예: progress 값을 조금씩 증가시키고, 이를 통해 게이지를 업데이트
            let newProgress = min(self.progress + 0.1, 1)
            self.progress = newProgress
        }
    }
}


