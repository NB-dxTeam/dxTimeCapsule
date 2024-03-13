//
//  MainCapsuleViewController.swift
//  dxTimeCapsule

//  Created by 김우경 on 2/23/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class MainCapsuleViewController: UIViewController {
    private var viewModel = MainCapsuleViewModel()
    var documentId: String?

    //장소명
    private lazy var locationName: UILabel = {
        let label = UILabel()
        label.text = "제주 국제 공항"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    //생성일
    private lazy var creationDateLabel: UILabel = {
        let label = UILabel()
        label.text = "생성일: "
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    //D-day
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.daysUntilOpening
        return label
    }()
    
    //캡슐이미지
    private lazy var capsuleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TimeCapsule")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // 이미지 뷰가 사용자 인터랙션을 받을 수 있도록 설정
        return imageView
    }()
    
    // BackLight 이미지
//    private lazy var backLightImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "BackLight")
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
    
    //개봉일이되었을때 생성되는 tap 안내문구
    private lazy var openCapsuleLabel: UILabel = {
        let label = UILabel()
        label.text = "타임캡슐을 오픈하세요!"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .systemBlue
        label.isHidden = true // D-day 전까지는 숨깁니다.
        return label
    }()
    
    // Firestore에서 사용자의 타임캡슐 정보를 불러오는 메소드
    func fetchTimeCapsuleData() {
        let db = Firestore.firestore()
        
        // 로그인한 사용자의 UID를 가져옵니다.
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
//        let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2" // 테스트를 위한 임시 UID

        // 사용자의 UID로 필터링하고, openDate 필드로 오름차순 정렬한 후, 최상위 1개 문서만 가져옵니다.
           db.collection("timeCapsules")
             .whereField("uid", isEqualTo: userId)
             .whereField("isOpened", isEqualTo: false) // 아직 열리지 않은 타임캡슐만 선택
             .order(by: "openDate", descending: false) // 가장 먼저 개봉될 타임캡슐부터 정렬
             .limit(to: 1) // 가장 개봉일이 가까운 타임캡슐 1개만 선택
             .getDocuments { [weak self] (querySnapshot, err) in
                           guard let self = self else { return }
                           if let err = err {
                               print("Error getting documents: \(err)")
                     
                 } else if let document = querySnapshot?.documents.first { // 첫 번째 문서만 사용
                     self.documentId = document.documentID // documentId 업데이트
                    
                     // 문서에서 "userLocation" 필드의 값을 가져옵니다.
                     let userLocation = document.get("userLocation") as? String ?? "Unknown Location"
                     print("Fetched location: \(userLocation)")
                     
                     // 메인 스레드에서 UI 업데이트를 수행합니다.
                     DispatchQueue.main.async {
                         self.locationName.text = userLocation
                     }
                     
                // 생성일 필드 값 가져오기
                if let creationDate = document.get("creationDate") as? Timestamp {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateStr = dateFormatter.string(from: creationDate.dateValue())
                    DispatchQueue.main.async {
                        self.creationDateLabel.text = "\(dateStr) 생성된 캡슐"
                        }
                    }
                 } else {
                               print("No documents found") // 문서가 없는 경우 로그 추가
                           }
                 }
             }
       

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        setupBackLightLayout()
        setupLayout()
        addTapGestureToCapsuleImageView()
        // D-day 확인 후 레이블 표시 로직
        checkIfItsOpeningDay()
        fetchTimeCapsuleData()
    }
    
//    private func setupBackLightLayout() {
//        view.addSubview(backLightImageView)
//        backLightImageView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview() // X축은 중앙
//            make.centerY.equalToSuperview().offset(-25) // Y축은 중앙에서 0만큼 위로 올림
//            make.width.equalTo(420) // backLight 이미지 너비
//            make.height.equalTo(360) // backLight 이미지 높이
//        }
//    }
    
    private func setupLayout() {
        view.addSubview(capsuleImageView)
        view.addSubview(openCapsuleLabel)
        view.addSubview(creationDateLabel)
        [locationName, daysLabel,].forEach { view.addSubview($0) }
        
        // 캡슐 이미지
        capsuleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo(400)
            make.height.equalTo(400)
        }
        
        // "타임캡슐을 오픈하세요!"
        openCapsuleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(capsuleImageView.snp.bottom).offset(5) // 이미지 아래에 위치
        }
        
        // 장소명
        locationName.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalToSuperview()
        }
        
        // D-day
        daysLabel.snp.makeConstraints { make in
            make.top.equalTo(locationName.snp.bottom).offset(460)
            make.centerX.equalToSuperview()
        }
        
        // 생성 날짜
        creationDateLabel.snp.makeConstraints { make in
            make.top.equalTo(daysLabel.snp.bottom).offset(5) // D-day 레이블 아래에 위치
            make.centerX.equalToSuperview()
        }
    }
    
    //탭 제스처 인식기 추가
    private func addTapGestureToCapsuleImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnCapsule))
        capsuleImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTapOnCapsule() {
        
        // 애니메이션 동작시 다른 UI 요소 숨기기
//           backLightImageView.isHidden = true
           creationDateLabel.isHidden = true
           locationName.isHidden = true
           daysLabel.isHidden = true
           openCapsuleLabel.isHidden = true
        
        addShakeAnimation()
        // 흔들림 애니메이션 총 지속 시간보다 약간 짧은 딜레이 후에 페이드아웃 및 확대 애니메이션 시작
        // 예시) 흔들림 애니메이션 지속 시간이 0.5초라면, 0.4초 후에 시작하도록 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.addFadeOutAndScaleAnimation()
        }
    }

    private func addShakeAnimation() {
        // 총 애니메이션 시간과 흔들림 횟수
        let totalDuration: TimeInterval = 0.5
        let numberOfShakes: Int = 10
        let animationDuration: TimeInterval = totalDuration / TimeInterval(numberOfShakes)
        
        for i in 0..<numberOfShakes {
            UIView.animate(withDuration: animationDuration, delay: animationDuration * TimeInterval(i), options: [.curveEaseInOut], animations: {
                // 홀수 번째는 오른쪽으로, 짝수 번째는 왼쪽으로 흔들립니다.
                self.capsuleImageView.transform = i % 2 == 0 ? CGAffineTransform(rotationAngle: 0.03) : CGAffineTransform(rotationAngle: -0.03)
            }) { _ in
                // 마지막 흔들림 후에 원래 상태로
//                if i == numberOfShakes - 1 {
//                    self.capsuleImageView.transform = CGAffineTransform.identity
//                }
            }
        }
    }

    private func addFadeOutAndScaleAnimation() {
        // 페이드아웃과 확대 애니메이션 동시에 적용
        UIView.animate(withDuration: 1.0, animations: {
            self.capsuleImageView.alpha = 0
            // x,y 값으로 확대값 설정
            self.capsuleImageView.transform = self.capsuleImageView.transform.scaledBy(x: 5.0, y: 5.0)
        }) { [weak self] _ in
                   guard let self = self, let documentId = self.documentId else { return }
            // 애니메이션이 완료된 인터렉션뷰로 전환
            self.navigateToOpenInteractionViewController(with: documentId)
        }
    }
    
    // OpenInteractionViewController로 네비게이션
    private func navigateToOpenInteractionViewController(with documentID: String) {
        let openInteractionVC = OpenInteractionViewController()
        
        openInteractionVC.documentId = documentId // documentId 전달
        openInteractionVC.modalPresentationStyle = .custom // 커스텀 모달 스타일 사용
        openInteractionVC.transitioningDelegate = self // 트랜지션 델리게이트 지정
        openInteractionVC.modalPresentationStyle = .fullScreen
         self.present(openInteractionVC, animated: true, completion: nil)
    }

    //현재 날짜와 타임캡슐의 개봉일을 비교하는 로직을 가져와 디데이에 신호를 주는것으로 변경 (아직 모르겟음)
    private func checkIfItsOpeningDay() {
        let isDdayOrLater = true // 실제 조건에 따라 변경
        if isDdayOrLater {
            openCapsuleLabel.isHidden = false
        }
    }
    
    // D-day 상황을 시뮬레이션하기 위해 수정
    private func simulateOpeningDay() {
        // 임시 D-day 시뮬레이션
        let isDdayOrLater = true // 실제 조건에 따라 변경
        if isDdayOrLater {
            openCapsuleLabel.isHidden = false
        }
    }
    
//    @objc private func openTimeCapsule() {
//        // 여기에 타임캡슐을 오픈할 때의 애니메이션과 로직을 구현
//        print("타임캡슐 오픈 로직을 구현")
//    }
}

extension MainCapsuleViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInAnimator() // 모달 표시시 사용할 애니메이터를 반환
    }
}
