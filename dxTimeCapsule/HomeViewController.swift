//
//  HomeViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 2/23/24.
//

import UIKit
import SnapKit


class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    
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
    
    // 친구 찾기 버튼
    let findFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "State=true"), for: .normal)
        button.addTarget(self, action: #selector(findFriendButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()

    //알림 버튼 생성
    let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    // 메뉴 버튼 생성
    let menuButton: UIButton = {
    let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.horizontal.3"),for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
    return button
    }()
    
    // 스택뷰
    let userStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    // 프로필 이미지뷰
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profilePic"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    // 사용자 ID 레이블
    let userIdLabel: UILabel = {
        let label = UILabel()
        label.text = "사용자 ID"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    // 날씨 정보 레이블
    let weatherLabel: UILabel = {
        let label = UILabel()
        label.text = "날씨 정보"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    // 메인 타임캡슐 그림자
    let maincontainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 4)
        view.layer.shadowRadius = 7
        return view
    }()
    
    // 메인 타임캡슐 이미지뷰
    let mainTCImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "duestTC"))
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // D-Day 레이블
    let dDayLabel: UILabel = {
        let label = UILabel()
        label.text = "D-DAY"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return label
    }()
    
    // 위치 레이블
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "서울시 양천구 신월동"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return label
    }()
    
    // 타임캡슐 보러가기 레이블
    let checkDuestTCLabel: UILabel = {
        let label = UILabel()
        label.text = "이 타임캡슐 보러가기 >>"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return label
    }()
    
    // 새로운 타임캡슐 만들기 버튼 생성
    let addNewTCButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("새로운 타임캡슐 만들기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 113/255, green: 183/255, blue: 246/255, alpha: 1.0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .black)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(addNewTCButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 열어본 타임캡슐 뷰어
    let openedContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 163/255, green: 201/255, blue: 246/255, alpha: 1.0)
        view.layer.cornerRadius = 20
        return view
    }()
    
    // 열어본 타임캡슐 라벨
    let openedTCLabel: UILabel = {
        let label = UILabel()
        label.text = "열어본 타임 캡슐"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    // 추억 회상하기 라벨
    let memoryLabel: UILabel = {
        let label = UILabel()
        label.text = "추억 회상하기"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // 추억 회상2 레이블
    let memorySecondLabel: UILabel = {
        let label = UILabel()
        label.text = "타입 캡슐을 타고 잊혀진 추억을 찾아보세요"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    // Opened Label StackView 생성
    lazy var openedLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 3
        stackView.addArrangedSubview(self.memoryLabel)
        stackView.addArrangedSubview(self.memorySecondLabel)
        return stackView
    }()
    
    // Opened TCStackView 생성
    lazy var openedTCStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.addArrangedSubview(self.memoryThirdLabel)
        stackView.addArrangedSubview(self.openedLabelStackView)
        stackView.addArrangedSubview(self.openedTCButton)
        return stackView
    }()
    
    // 추억 회상3 라벨
    let memoryThirdLabel: UILabel = {
        let label = UILabel()
        label.text = "💡"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 113/255, green: 183/255, blue: 246/255, alpha: 1.0)
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    // 열어본 타임캡슐 버튼
    let openedTCButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("〉", for: .normal)
        button.setTitleColor(. black , for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .black)
        button.addTarget(self, action: #selector(openedTCButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 다가오는 타임캡슐 뷰어
    let upcomingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // 다가오는 타임캡슐 라벨
    let upcomingLabel: UILabel = {
        let label = UILabel()
        label.text = "다가오는 타임 캡슐"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    // 다가오는 타임캡슐 전체 보기 버틈
    let upcomingOpenbutton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체 보기 >", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        button.addTarget(self, action: #selector(upcomingTCButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Collection View

    // 열어 본 타임캡슐 컬렉션 뷰
    lazy var openedcollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "openedCellIdentifier")
        return collectionView
    }()
    
    // 다가오는 타임캡슐 컬렉션 뷰
    lazy var upcomingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "upcomingCellIdentifier")
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        openedcollectionView.layoutIfNeeded()
        upcomingCollectionView.layoutIfNeeded()
    
        // 열어 본 타임캡슐 컬렉션 뷰 레이아웃 설정
        let openedLayout = UICollectionViewFlowLayout()
        openedLayout.scrollDirection = .horizontal
        openedLayout.itemSize = CGSize(width: openedcollectionView.frame.height, height: openedcollectionView.frame.height)
        openedLayout.minimumLineSpacing = 10
        openedcollectionView.collectionViewLayout = openedLayout

        // 다가오는 타임캡슐 컬렉션 뷰 레이아웃 설정
        let upcomingLayout = UICollectionViewFlowLayout()
        upcomingLayout.scrollDirection = .horizontal
        upcomingLayout.itemSize = CGSize(width: upcomingCollectionView.frame.height, height: upcomingCollectionView.frame.height)
        upcomingLayout.minimumLineSpacing = 10
        upcomingCollectionView.collectionViewLayout = upcomingLayout
    }
    
    // MARK: - Helpers
    
    private func configureUI(){
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        openedcollectionView.register(OpenedTCCollectionViewCell.self, forCellWithReuseIdentifier: "openedCellIdentifier")
        upcomingCollectionView.register(UpcomingTCCollectionViewCell.self, forCellWithReuseIdentifier: "upcomingCellIdentifier")
        // 커스텀 네비게이션 바 추가
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
                   
        // pagelogo 이미지뷰 추가
        customNavBar.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.centerY.equalTo(customNavBar)
            make.left.equalTo(customNavBar).offset(20)
            make.width.equalTo(170)
        }
                
        // 메뉴 버튼 추가
        customNavBar.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(customNavBar)
            make.right.equalTo(customNavBar).offset(-20)
        }
                   
        // 알림 버튼 추가
        customNavBar.addSubview(notificationButton)
        notificationButton.snp.makeConstraints { make in
            make.centerY.equalTo(customNavBar)
            make.right.equalTo(menuButton.snp.left).offset(-16)
        }
        
        // 스택뷰 추가
        view.addSubview(userStackView)
        userStackView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 프로필 이미지뷰 추가
        profileImageView.snp.makeConstraints { make in
               make.width.height.equalTo(40)
           }
           userStackView.addArrangedSubview(profileImageView)
        
        // 사용자 ID 레이블 추가
        userStackView.addArrangedSubview(userIdLabel)
        
        // 날씨 정보 레이블 추가
        userStackView.addArrangedSubview(weatherLabel)
        // 메인 타임캡슐 그림자 추가
        view.addSubview(maincontainerView)
        maincontainerView.snp.makeConstraints { make in
             make.top.equalTo(userStackView.snp.bottom).offset(20)
             make.leading.trailing.equalToSuperview().inset(20)
             make.height.equalToSuperview().multipliedBy(0.2)
                  }
              
        // 메인 타임캡슐 이미지뷰 추가
        mainTCImageView.isUserInteractionEnabled = true
        view.addSubview(mainTCImageView)
        mainTCImageView.snp.makeConstraints { make in
            make.top.equalTo(userStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        mainTCImageView.layer.cornerRadius = 20
        mainTCImageView.layer.masksToBounds = true
        mainTCImageView.layer.shadowColor = UIColor.black.cgColor
        mainTCImageView.layer.shadowOpacity = 0.5
        mainTCImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainTCImageView.layer.shadowRadius = 4

        
        // D-Day 레이블 추가
        mainTCImageView.addSubview(dDayLabel)
        dDayLabel.snp.makeConstraints { make in
            make.top.equalTo(mainTCImageView).offset(15)
            make.left.equalTo(mainTCImageView).offset(15)
        }
        
        // 위치 레이블 추가
        mainTCImageView.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(mainTCImageView)
        }
        
        // 타임캡슐 보러가기 레이블 추가
        mainTCImageView.addSubview(checkDuestTCLabel)
        checkDuestTCLabel.snp.makeConstraints { make in
            make.bottom.equalTo(mainTCImageView).offset(-10)
            make.right.equalTo(mainTCImageView).offset(-10)
        }
        
        // 메인 타임캡슐 이미지뷰에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mainTCImageViewTapped))
        mainTCImageView.addGestureRecognizer(tapGesture)
        
        // 새로운 타임캡슐 만들기 버튼 추가
        view.addSubview(addNewTCButton)
        addNewTCButton.snp.makeConstraints { make in
            make.top.equalTo(mainTCImageView.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(100)
            make.height.equalTo(40)
        }
        
        // 열어본 타임 캡슐 라벨 추가
        openedContainerView.addSubview(openedTCLabel)
        openedTCLabel.snp.makeConstraints { make in
            make.top.equalTo(openedContainerView).offset(-20)
            make.left.equalTo(openedContainerView).offset(10)
        }
     
        // 컨테이너 뷰(열어본 타임캡슐)
        view.addSubview(openedContainerView)
        openedContainerView.snp.makeConstraints { make in
            make.top.equalTo(addNewTCButton.snp.bottom).offset(45)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        // 컨테이너뷰에 컬렉션 뷰 추가
        view.addSubview(openedcollectionView)
        openedcollectionView.snp.makeConstraints { make in
            make.top.equalTo(openedContainerView.snp.top).offset(10)
            make.leading.equalTo(openedContainerView.snp.leading).offset(10)
            make.trailing.equalTo(openedContainerView.snp.trailing).offset(-10)
            make.height.equalTo(openedContainerView.snp.height).multipliedBy(3.0/5.0)
        }

        openedContainerView.addSubview(openedTCStackView)
        openedTCStackView.snp.makeConstraints { make in
            make.bottom.equalTo(openedContainerView.snp.bottom).offset(-10)
            make.leading.equalTo(openedContainerView.snp.leading).offset(10)
            make.trailing.equalTo(openedContainerView.snp.trailing).offset(-10)
            make.height.equalTo(openedContainerView.snp.height).multipliedBy(1.0/5.0)
        }

        openedTCButton.snp.makeConstraints { make in
            make.width.equalTo(openedTCButton.snp.height)
        }

        memoryThirdLabel.snp.makeConstraints { make in
            make.width.equalTo(memoryThirdLabel.snp.height)
        }

        view.addSubview(upcomingCollectionView)

        // 다가오는 타임 캡슐 라벨
        view.addSubview(upcomingLabel)
        upcomingLabel.snp.makeConstraints { make in
            make.top.equalTo(upcomingCollectionView.snp.top).offset(-25)
            make.leading.equalTo(upcomingCollectionView.snp.leading).offset(10)
        }

        upcomingCollectionView.snp.makeConstraints { make in
            make.top.equalTo(openedContainerView.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.15)
        }
        
        view.addSubview(upcomingOpenbutton)
        upcomingOpenbutton.snp .makeConstraints { make in
            make.top.equalTo(upcomingCollectionView.snp.top).offset(-30)
            make.trailing.equalTo(upcomingCollectionView.snp.trailing).offset(-10)
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

// MARK: - UICollectionViewDataSource

// 첫 번째 컬렉션 뷰 데이터 소스 및 델리게이트
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == openedcollectionView {
            return 20
        } else if collectionView == upcomingCollectionView {
            return 25
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == openedcollectionView {
            let collectionViewHeight = openedcollectionView.frame.height
            return CGSize(width: collectionViewHeight*1.1, height: collectionViewHeight)
        } else if collectionView == upcomingCollectionView {
            let collectionViewHeight = upcomingCollectionView.frame.height
            return CGSize(width: collectionViewHeight*1.2, height: collectionViewHeight-25)
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == openedcollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "openedCellIdentifier", for: indexPath)
            cell.backgroundColor = .systemCyan
            return cell
        } else if collectionView == upcomingCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingCellIdentifier", for: indexPath)
            cell.backgroundColor = .systemYellow
            return cell
        } else {
            fatalError("Unexpected collection view")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // 첫 번째 컬렉션 뷰(열어 본 타임캡슐)의 각 섹션에 대한 수평 간격 설정
        if collectionView == openedcollectionView {
            // 첫 번째 섹션의 수평 간격은 10, 두 번째 섹션의 수평 간격은 20으로 설정
            return 10
        }
        
        // 두 번째 컬렉션 뷰(다가오는 타임캡슐)의 각 섹션에 대한 수평 간격 설정
        if collectionView == upcomingCollectionView {
            // 모든 섹션의 수평 간격을 동일하게 15로 설정
            return 15
        }
        
        // 기본 수평 간격 반환
        return 10
    }
}
