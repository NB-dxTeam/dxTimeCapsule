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
    
    private var openDate: Date?
    
    private var stackView: UIStackView!
    
    // 빨간색 배경 뷰 설정
    private lazy var dDayBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .red // 배경색은 빨간색
        view.layer.cornerRadius = 13 // 모서리 둥글기 반지름 설정
        view.clipsToBounds = true // 모서리 둥글기 적용을 위해 필요
        view.layer.borderWidth = 1 // 테두리 두께
        view.layer.borderColor = UIColor.red.cgColor // 테두리 색상은 빨간색
        return view
    }()

    // D-day 레이블 설정
    private lazy var dDayLabel: UILabel = {
        let label = UILabel()
        label.text = "D-100" // 예시 텍스트
        label.textColor = .white // 텍스트 색상은 흰색
        label.font = .systemFont(ofSize: 18, weight: .bold) // 폰트 크기 및 스타일 설정
        label.textAlignment = .center // 텍스트 가운데 정렬
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
        label.text = "상자를 눌러 타임캡슐을 오픈하세요!"
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
            } else if let document = querySnapshot?.documents.first {
                self.documentId = document.documentID
                
                // 문서에서 필드의 값을 가져옵니다.
                let userLocation = document.get("userLocation") as? String ?? "Unknown Location"
                let detailedLocation = document.get("location") as? String ?? "No detailed address available"
                if let openDateTimestamp = document.get("openDate") as? Timestamp {
                    let openDate = openDateTimestamp.dateValue()
                    self.openDate = openDate // 전역 변수에 openDate 저장
                    
                    // D-day 계산 로직을 위해 dDayCalculation 구조체의 인스턴스를 생성합니다.
                    let dDayCalculator = dDayCalculation(openDate: openDate)
                    
                    DispatchQueue.main.async {
                        self.locationName.text = userLocation
                        self.detailedLocationLabel.text = detailedLocation
                     
                        let calendar = Calendar.current
                        let startDate = calendar.startOfDay(for: Date()) // 오늘 날짜의 자정
                        let endDate = calendar.startOfDay(for: openDate) // 개봉일 날짜의 자정

                        // D-day 문자열 계산
                        let dDayString = dDayCalculator.dDay()
                        self.dDayLabel.text = dDayString
                        
                        // 개봉일 당일에도 탭을 활성화하기 위한 조건 추가
                        if startDate < endDate {
                            // D-day 미도달: 오픈 불가능
                            self.openCapsuleLabel.isHidden = true
                            self.capsuleImageView.isUserInteractionEnabled = false
                        } else {
                            // D-day 도달or지남: 오픈 가능
                            self.openCapsuleLabel.isHidden = false
                            self.capsuleImageView.isUserInteractionEnabled = true
                        }
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
                print("No documents found")
            }
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        setupBackLightLayout()
        setupLayout()
        addTapGestureToCapsuleImageView()
        checkIfItsOpeningDay()
        fetchTimeCapsuleData()
        setupStackView()
        setupDetailedLocationLabel()
    }

    private func setupStackView() {
        dDayBackgroundView.addSubview(dDayLabel)
        
        // dDayLabel의 레이아웃을 dDayBackgroundView 내부 중앙에 맞춤
        dDayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)) // 여백 조정
        }
        
        self.stackView = UIStackView(arrangedSubviews: [dDayBackgroundView, locationName])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
        }
    }

    // 상세 주소 레이블 레이아웃 설정을 담당하는 별도의 메서드
    private func setupDetailedLocationLabel() {
        view.addSubview(detailedLocationLabel)
        detailedLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
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
        [locationName, dDayLabel,].forEach { view.addSubview($0) }
        
        // 캡슐 이미지
        capsuleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo(400)
            make.height.equalTo(400)
        }
        
        // 생성 날짜
        creationDateLabel.snp.makeConstraints { make in
            make.top.equalTo(capsuleImageView.snp.bottom).offset(1) // 이미지 아래에 위치
            make.centerX.equalToSuperview()
        }
        
        // "타임캡슐을 오픈하세요!"
        openCapsuleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(creationDateLabel.snp.bottom).offset(5) // 오픈캡슐 레이블 아래에 위치
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
        
    }
    
    //탭 제스처 인식기 추가
    private func addTapGestureToCapsuleImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnCapsule))
        capsuleImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTapOnCapsule() {
        guard let openDate = self.openDate else {
            // 개봉일 정보가 없는 경우, 함수 실행 중지
            return
        }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date()) // 현재 날짜의 자정
        let openDateStart = calendar.startOfDay(for: openDate) // 개봉일의 자정

        if startDate >= openDateStart {
            // 개봉일 당일이거나 지난 경우, 타임캡슐 개봉 애니메이션 실행
            hideUIComponentsForOpening() // UI 요소 숨김 처리

            addShakeAnimation() // 흔들림 애니메이션 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.addFadeOutAndScaleAnimation() // 페이드아웃 및 확대 애니메이션 시작
            }
        } else {
            // D-day 미도달: 아직 타임캡슐을 오픈할 수 없음
        }
    }

    private func hideUIComponentsForOpening() {
        // backLightImageView.isHidden = true // 필요하다면 주석 해제
        creationDateLabel.isHidden = true
        locationName.isHidden = true
        dDayLabel.isHidden = true
        openCapsuleLabel.isHidden = true
        detailedLocationLabel.isHidden = true
        dDayBackgroundView.isHidden = true
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
}

extension MainCapsuleViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInAnimator() // 모달 표시시 사용할 애니메이터를 반환
    }
}
