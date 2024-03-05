//
//  HomeViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 2/23/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth


class HomeViewController: UIViewController {

    // MARK: - Properties
    
    // 커스텀 네비게이션 바
    let customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // pagelogo 이미지뷰 생성
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pagelogo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //알림 버튼 생성
    let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
   
    // 메인 타임캡슐 그림자
    let mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 4)
        view.layer.shadowRadius = 7
        return view
    }()
    
    // 메인 타임캡슐 이미지뷰
    let mainTCImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "location"))
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 장소 레이블
    let locationNameLabel: UILabel = {
        let label = UILabel()
        label.text = "서서울호수공원"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .black
        return label
    }()
    
    
    // 위치 레이블
    let locationAddressLabel: UILabel = {
        let label = UILabel()
        label.text = "서울시 양천구 신월동"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    
    // D-Day 레이블
    let dDayLabel: UILabel = {
        let label = UILabel()
        label.text = "D-DAY"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .red
        return label
    }()

    // 장소정보 스택뷰
    lazy var locationInforStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.addArrangedSubview(self.locationNameLabel)
        stackView.addArrangedSubview(self.locationAddressLabel)
        return stackView
    }()
    
    // DuestTC 스택뷰
    lazy var duestTCInforStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.addArrangedSubview(self.locationInforStackView)
        stackView.addArrangedSubview(self.dDayLabel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(duestTCStackViewTapped))
        stackView.addGestureRecognizer(tapGesture)
        stackView.isUserInteractionEnabled = true
        
        return stackView
    }()
    
    func fetchTimeCapsuleData() {
        let db = Firestore.firestore()
        
        // 로그인한 사용자의 UID를 가져옵니다.
        //    guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2" // 테스트를 위한 임시 UID
        
        // 사용자의 UID로 필터링하고, openDate 필드로 오름차순 정렬한 후, 최상위 1개 문서만 가져옵니다.
        db.collection("timeCapsules")
                .whereField("uid", isEqualTo: userId)
                .whereField("isOpened", isEqualTo: false) // isOpened가 false인 경우 필터링
                .order(by: "openDate", descending: false) // 가장 먼저 개봉될 타임캡슐부터 정렬
                .limit(to: 1) // 가장 개봉일이 가까운 타임캡슐 1개만 선택
                .getDocuments { [weak self] (querySnapshot, err) in
                    guard let self = self else { return }
                    
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if let document = querySnapshot?.documents.first { // 첫 번째 문서만 사용
                        let userLocation = document.get("userLocation") as? String ?? "Unknown Location"
                        let location = document.get("location") as? String ?? "Unknown address"
                        let tcBoxImageURL = document.get("tcBoxImageURL") as? String ?? ""
                        let openDateTimestamp = document.get("openDate") as? Timestamp
                        let openDate = openDateTimestamp?.dateValue()
                        
                        print("Fetched location name: \(userLocation)")
                        print("Fetched location address: \(location)")
                        print("Fetched photo URL: \(tcBoxImageURL)")
                        print("Fetched open date: \(openDate)")
                        
                        // 메인 스레드에서 UI 업데이트를 수행합니다.
                        DispatchQueue.main.async {
                            self.locationNameLabel.text = userLocation
                            self.locationAddressLabel.text = location
                            
                            // D-Day 계산
                            if let openDate = openDate {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // UTC+9:00

                                let today = Date()
                                let calendar = Calendar.current
                                let components = calendar.dateComponents([.day], from: today, to: openDate)

                                if let daysUntilOpening = components.day {
                                    // 날짜 차이에 따라 표시되는 기호를 변경하여 D-Day 표시
                                    let dDayPrefix = daysUntilOpening <= 0 ? "D+" : "D-"
                                    self.dDayLabel.text = "\(dDayPrefix)\(abs(daysUntilOpening))"
                                }
                            }
                            
                            if !tcBoxImageURL.isEmpty {
                                guard let url = URL(string: tcBoxImageURL) else {
                                    print("Invalid photo URL")
                                    return
                                }
                                
                                URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    if let error = error {
                                        print("Error downloading image: \(error)")
                                        return
                                    }
                                    
                                    guard let data = data else {
                                        print("No image data")
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.mainTCImageView.image = UIImage(data: data)
                                    }
                                }.resume()
                            }
                        }
                    }
                }
        }
    
    // 열어본 타임캡슐 버튼
    let openedTCButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "duestTC")?.withRenderingMode(.alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openedTCButtonTapped), for: .touchUpInside)
        
        // 버튼 내에 UILabel 추가
        let titleLabel = UILabel()
        titleLabel.text = "Saved\nmemories"
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // UILabel을 버튼에 추가
        button.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return button
    }()

    // 다가오는 타임캡슐 버튼
    let upcomingTCButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "upcomingTC")?.withRenderingMode(.alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(upcomingTCButtonTapped), for: .touchUpInside)
        
        // 버튼 내에 UILabel 추가
        let titleLabel = UILabel()
        titleLabel.text = "Upcoming\nmemories"
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // UILabel을 버튼에 추가
        button.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return button
    }()
    
    // 버튼 스택뷰
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [openedTCButton, upcomingTCButton])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually // 크기를 동일하게 설정
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        configureUI()
        fetchTimeCapsuleData()
    }
    
    // MARK: - Helpers
    
    private func configureUI(){

        // 커스텀 네비게이션 바 추가
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
                   
        // pagelogo 이미지뷰 추가
        customNavBar.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.centerY.equalTo(customNavBar)
            make.left.equalTo(customNavBar).offset(20)
            make.width.equalTo(170)
        }
                   
        // 알림 버튼 추가
        customNavBar.addSubview(notificationButton)
        notificationButton.snp.makeConstraints { make in
            make.centerY.equalTo(customNavBar)
            make.right.equalTo(customNavBar).offset(-20)
        }
        
        // 메인 타임캡슐 그림자 추가
        view.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints { make in
             make.top.equalTo(customNavBar.snp.bottom).offset(30)
             make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(2.0/6.0)
                  }
              
        // mainTCImageView를 maincontainerView에 추가
        mainContainerView.addSubview(mainTCImageView)
        mainTCImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainTCImageView.layer.cornerRadius = 10
        mainTCImageView.layer.masksToBounds = true
        mainTCImageView.layer.shadowColor = UIColor.black.cgColor
        mainTCImageView.layer.shadowOpacity = 0.5
        mainTCImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainTCImageView.layer.shadowRadius = 4

        // infoAndDdayStackView의 위치 설정
        view.addSubview(duestTCInforStackView)
        duestTCInforStackView.snp.makeConstraints { make in
            make.top.equalTo(mainContainerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
            // 높이는 maincontainerView의 너비의 1/5로 설정
            make.height.equalToSuperview().multipliedBy(0.5/6.0)
        }
        
        // locationInforStackView의 위치 설정
        locationInforStackView.snp.makeConstraints { make in
            make.top.equalTo(mainContainerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
            make.height.equalTo(mainContainerView.snp.width).multipliedBy(1.0/5.0)
        }

        // userLocationLabel의 슈퍼뷰 설정
        locationNameLabel.snp.makeConstraints { make in
            make.height.equalTo(locationNameLabel.font.pointSize) // 폰트 크기에 맞는 높이로 설정
        }

        // locationLabel의 슈퍼뷰 설정
        locationAddressLabel.snp.makeConstraints { make in
            make.height.equalTo(locationAddressLabel.font.pointSize) // 폰트 크기에 맞는 높이로 설정
        }

        // dDayLabel의 슈퍼뷰 설정
        view.addSubview(dDayLabel)
        dDayLabel.snp.makeConstraints { make in
            make.top.equalTo(mainContainerView.snp.bottom).inset(5)
            make.width.equalTo(mainContainerView.snp.width).multipliedBy(1.0/5.0)
            make.height.equalTo(mainContainerView.snp.width).multipliedBy(1.0/5.0)
            make.trailing.equalToSuperview().inset(5)
        }
        
        
        // 메인 타임캡슐 이미지뷰에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mainTCImageViewTapped))
        mainTCImageView.addGestureRecognizer(tapGesture)
        
        // 버튼 스택뷰에 버튼 추가
        buttonStackView.addArrangedSubview(openedTCButton)
        buttonStackView.addArrangedSubview(upcomingTCButton)
        
        // 버튼 스택뷰를 뷰에 추가
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(duestTCInforStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(1.5/6.0)// 버튼 높이 조정
        }
        
    }
    
    // MARK: - Actions
    
    @objc func menuButtonTapped() {
        print("메뉴 버튼이 클릭되었습니다")
        let userProfileVC = UserProfileViewController()
        let navController = UINavigationController(rootViewController: userProfileVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func notificationButtonTapped() {
        print("알림 버튼이 클릭되었습니다")
        let notificationVC = NotificationViewController()
        let navController = UINavigationController(rootViewController: notificationVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func duestTCStackViewTapped() {
        print("DuestTC 스택뷰가 클릭되었습니다")
        let mainCapsuleVC = MainCapsuleViewController()
        let navController = UINavigationController(rootViewController: mainCapsuleVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func mainTCImageViewTapped() {
        print("메인 타임캡슐 보러가기 버튼이 클릭되었습니다")
        let mainCapsuleVC = MainCapsuleViewController()
        let navController = UINavigationController(rootViewController: mainCapsuleVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func addNewTCButtonTapped() {
        print("새로운 타임캡슐 만들기 버튼이 클릭되었습니다")
        let createTCVC = MainCreateCapsuleViewController()
        let navController = UINavigationController(rootViewController: createTCVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func openedTCButtonTapped(){
        print("열어본 타임캡슐 열기 버튼이 클릭되었습니다")
        let openedVC = OpenedTCViewController()
        let navController = UINavigationController(rootViewController: openedVC)
        present(navController, animated: true, completion: nil)
        
    }
    
    @objc func upcomingTCButtonTapped(){
        print("다가오는 타임캡슐 열기 버튼이 클릭되었습니다")
        let upcomingVC = CapsuleMapViewController()
        let navController = UINavigationController(rootViewController: upcomingVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func findFriendButtonTapped(){
        print("다가오는 타임캡슐 열기 버튼이 클릭되었습니다")
        let serarchUserVC = SearchUserViewController()
        let navController = UINavigationController(rootViewController: serarchUserVC)
        present(navController, animated: true, completion: nil)
    }
}
