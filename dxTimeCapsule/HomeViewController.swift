//
//  HomeViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 2/23/24.
//

import UIKit
import SnapKit

#Preview{
   HomeViewController()
}

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    // 스크롤 뷰
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    // 모든 UI 요소들을 포함할 컨테이너 뷰
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
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
    let containerView: UIView = {
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
        stackView.addArrangedSubview(self.openedMemoryButton)
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
    
    // 추억 회상 버튼
    let openedMemoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("〉", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        let buttonSize: CGFloat = 40 // 버튼의 크기 설정
        button.layer.cornerRadius = buttonSize / 2 // 버튼을 원형으로 만들기 위해 반지름 설정
        button.clipsToBounds = true // 버튼 경계 내의 콘텐츠만 보이도록 설정
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .black)
        button.addTarget(self, action: #selector(openedMemoryButtonTapped), for: .touchUpInside)
        return button
    }()

    
    // 다가오는 타임캡슐 라벨
    let upComingLabel: UILabel = {
        let label = UILabel()
        label.text = "다가오는 타임 캡슐"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
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
        collectionView.register(OpenedTCCollectionViewCell.self, forCellWithReuseIdentifier: "openedCellIdentifier")
        return collectionView
    }()
    
    // 다가오는 타임캡슐 컬렉션 뷰
    lazy var upComingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UpcomingTCCollectionViewCell.self, forCellWithReuseIdentifier: "upComingCellIdentifier")
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        openedcollectionView.layoutIfNeeded()
        
        // 열어 본 타임캡슐 컬렉션 뷰 레이아웃 설정
        let openedLayout = UICollectionViewFlowLayout()
        openedLayout.scrollDirection = .horizontal
        openedLayout.itemSize = CGSize(width: openedcollectionView.frame.height, height: openedcollectionView.frame.height)
        openedLayout.minimumLineSpacing = 10 // 가로 간격을 0으로 설정하여 한 줄에 하나의 셀만 보이도록 함
        openedcollectionView.collectionViewLayout = openedLayout

        // 다가오는 타임캡슐 컬렉션 뷰 레이아웃 설정
        let upComingLayout = UICollectionViewFlowLayout()
        upComingLayout.scrollDirection = .horizontal
        upComingLayout.itemSize = CGSize(width: upComingCollectionView.frame.height, height: upComingCollectionView.frame.height)
        upComingLayout.minimumLineSpacing = 10 // 가로 간격을 0으로 설정하여 한 줄에 하나의 셀만 보이도록 함
        upComingCollectionView.collectionViewLayout = upComingLayout

    
    }
    
    // MARK: - Helpers
    
    private func configureUI(){
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        openedcollectionView.register(OpenedTCCollectionViewCell.self, forCellWithReuseIdentifier: "openedCellIdentifier")
           upComingCollectionView.register(UpcomingTCCollectionViewCell.self, forCellWithReuseIdentifier: "upComingCellIdentifier")

        // 스크롤 뷰를 루트 뷰에 추가
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 스크롤 뷰에 컨텐츠 뷰 추가
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
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
            make.left.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
    
        // 메인 타임캡슐 이미지뷰 추가
        view.addSubview(mainTCImageView)
        mainTCImageView.snp.makeConstraints { make in
            make.top.equalTo(userStackView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        mainTCImageView.layer.cornerRadius = 20
        mainTCImageView.layer.masksToBounds = true
        
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
        containerView.addSubview(openedTCLabel)
        openedTCLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(-20)
            make.left.equalTo(containerView).offset(10)
        }
     
        // 컨테이너 뷰(열어본 타임캡슐)
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(addNewTCButton.snp.bottom).offset(45)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        // 컨테이너뷰에 컬렉션 뷰 추가
        view.addSubview(openedcollectionView)
        openedcollectionView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(15)
            make.leading.equalTo(containerView.snp.leading).offset(10)
            make.trailing.equalTo(containerView.snp.trailing).offset(-10)
            make.height.equalTo(containerView.snp.height).multipliedBy(3.0/5.0)
        }

        containerView.addSubview(openedTCStackView)
        openedTCStackView.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-15)
            make.leading.equalTo(containerView.snp.leading).offset(10)
            make.trailing.equalTo(containerView.snp.trailing).offset(-10)
            make.height.equalTo(containerView.snp.height).multipliedBy(1.0/5.0)
        }

        openedMemoryButton.snp.makeConstraints { make in
            make.width.equalTo(openedMemoryButton.snp.height)
        }

        memoryThirdLabel.snp.makeConstraints { make in
            make.width.equalTo(memoryThirdLabel.snp.height)
        }

        view.addSubview(upComingCollectionView)

        // 컨테이너뷰에 라벨 추가
        view.addSubview(upComingLabel)
        upComingLabel.snp.makeConstraints { make in
            make.top.equalTo(upComingCollectionView.snp.top).offset(-30)
            make.leading.equalTo(upComingCollectionView.snp.leading).offset(10)
        }

        upComingCollectionView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        // 컨텐츠 뷰에 다가오는 타임캡슐 컬렉션 뷰 추가
        contentView.addSubview(upComingCollectionView)
        upComingCollectionView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.25)
        }

        // 컨텐츠 뷰의 하단 제약을 추가하여 스크롤 가능한 영역을 설정합니다.
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
            make.bottom.equalTo(upComingCollectionView.snp.bottom).offset(1000)
        }
    }
    
    // MARK: - Actions
    
    @objc func menuButtonTapped() {
        print("메뉴 버튼이 클릭되었습니다")
        
    }
    
    @objc func notificationButtonTapped() {
        print("알림 버튼이 클릭되었습니다")
        
    }
    
    @objc private func mainTCImageViewTapped() {
        print("메인 타임캡슐 보러가기 버튼이 클릭되었습니다")
        let mainCapsuleVC = MainCapsuleViewController()
        let navController = UINavigationController(rootViewController: mainCapsuleVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func addNewTCButtonTapped() {
        print("새로운 타임캡슐 만들기 버튼이 클릭되었습니다")
    }
    
    @objc func openedMemoryButtonTapped(){
        print("저장된 타임캡슐 열기 버튼이 클릭되었습니다")
        
    }
}

// MARK: - UICollectionViewDataSource

// 첫 번째 컬렉션 뷰 데이터 소스 및 델리게이트
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == openedcollectionView {
            return 20 // 첫 번째 컬렉션 뷰의 아이템 개수 설정
        } else if collectionView == upComingCollectionView {
            return 25 // 두 번째 컬렉션 뷰의 아이템 개수 설정
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == openedcollectionView {
            let collectionViewHeight = openedcollectionView.frame.height
            return CGSize(width: 40, height: collectionViewHeight) // 첫 번째 컬렉션 뷰의 셀 크기 설정
        } else if collectionView == upComingCollectionView {
            let collectionViewHeight = upComingCollectionView.frame.height
            return CGSize(width: 50, height: collectionViewHeight) // 두 번째 컬렉션 뷰의 셀 크기 설정
        } else {
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == openedcollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "openedCellIdentifier", for: indexPath)
            cell.backgroundColor = .blue // 첫 번째 컬렉션 뷰의 셀 색상 설정
            return cell
        } else if collectionView == upComingCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upComingCellIdentifier", for: indexPath)
            cell.backgroundColor = .yellow // 두 번째 컬렉션 뷰의 셀 색상 설정
            return cell
        } else {
            fatalError("Unexpected collection view")
        }
    }
}
