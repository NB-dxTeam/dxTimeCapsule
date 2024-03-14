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
    
    // D-day 레이블 설정
    private lazy var dDayLabel: UILabel = {
        let label = UILabel()
        label.text = "D-100" // 예시 텍스트
        label.textColor = .white // 텍스트 색상은 흰색
        label.backgroundColor = .red // 배경색은 빨간색
        label.font = .systemFont(ofSize: 14, weight: .bold) // 볼드체 폰트 사용
        label.textAlignment = .center // 텍스트 가운데 정렬
        label.layer.cornerRadius = 10 // 모서리 둥글기 반지름 설정
        label.clipsToBounds = true // 모서리 둥글기 적용을 위해 필요
        label.layer.borderWidth = 1 // 테두리 두께
        label.layer.borderColor = UIColor.red.cgColor // 테두리 색상은 빨간색
        return label
    }()
    
    //장소명
    private lazy var locationName: UILabel = {
        let label = UILabel()
        label.text = "제주 국제 공항"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    //상세주소
    private lazy var detailedLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "상세 주소 정보 로딩 중..."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
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
                     
                     // 'location' 필드 값 가져오기 및 상세 주소 레이블 텍스트 설정
                     if let detailedLocation = document.get("location") as? String {
                         DispatchQueue.main.async {
                             self.detailedLocationLabel.text = detailedLocation
                         }
                     }
                     
                // 'openDate' 필드 값 가져오기 및 D-day 계산
                if let openDateTimestamp = document.get("openDate") as? Timestamp {
                    let openDate = openDateTimestamp.dateValue()
                    let dDayCalculation = dDayCalculation(openDate: openDate)
                    let dDayString = dDayCalculation.dDay()
                         
                    DispatchQueue.main.async {
                        self.dDayLabel.text = dDayString // D-day 표시 업데이트
                    }
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
        view.addSubview(dDayLabel)
        view.addSubview(locationName)
        view.addSubview(capsuleImageView)
        view.addSubview(openCapsuleLabel)
        view.addSubview(creationDateLabel)
        [locationName, dDayLabel,].forEach { view.addSubview($0) }
        
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

        // dDay 레이블 레이아웃 설정
           dDayLabel.snp.makeConstraints { make in
               make.leading.greaterThanOrEqualToSuperview().offset(8) // 화면 왼쪽 가장자리로부터 최소 8포인트 간격을 줍니다.
               make.trailing.lessThanOrEqualTo(locationName.snp.leading).offset(-8) // locationName과의 간격
               // dDayLabel의 중심이 locationName과 동일한 세로 축을 공유하도록 설정
               make.centerY.equalTo(locationName.snp.centerY)
           }
           
           // locationName 레이블 레이아웃 설정
           locationName.snp.makeConstraints { make in
               make.trailing.lessThanOrEqualToSuperview().offset(-8) // 화면 오른쪽 가장자리로부터 최소 8포인트 간격을 줍니다.
               // locationName 레이블의 중앙이 뷰의 중앙에 오도록 설정합니다.
               make.centerX.equalToSuperview()
               make.centerY.equalToSuperview().offset(-40) // 원하는 y축 위치로 조정
           }
           
           // dDay 레이블과 locationName 레이블이 서로 가운데 정렬이 되도록 조정합니다.
           dDayLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
           locationName.setContentCompressionResistancePriority(.required, for: .horizontal)
       
        
        // 상세 주소 레이블 레이아웃 설정
        view.addSubview(detailedLocationLabel)
        detailedLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(locationName.snp.bottom).offset(8) // locationName 아래에 위치
            make.centerX.equalToSuperview()
        }
        
        // 생성 날짜
        creationDateLabel.snp.makeConstraints { make in
            make.top.equalTo(openCapsuleLabel.snp.bottom).offset(50) // 오픈캡슐 레이블 아래에 위치
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
           dDayLabel.isHidden = true
           openCapsuleLabel.isHidden = true
           detailedLocationLabel.isHidden = true
        
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
