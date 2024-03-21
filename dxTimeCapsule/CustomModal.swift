//
//  CustomModal.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/28/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth



class CustomModal: UIViewController {
    
    var timeBoxes = [TimeBox]()
    var onCapsuleSelected: ((Double, Double) -> Void)? //선택된 위치 정보를 받아 처리하는 클로저
    private var headerCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.layer.cornerRadius = 20
        collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collection.layer.masksToBounds = true
        return collection
    }()
    private var capsuleCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        //collection.layer.cornerRadius = 10
       // collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collection.layer.masksToBounds = true
        return collection
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    private lazy var aBotton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        configCollection()
        fetchTimeCapsulesInfo()
    }
    // addsubView, autolayout
    private func setupUI() {
        view.addSubview(capsuleCollection)
        view.addSubview(headerCollection)
        headerCollection.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        capsuleCollection.snp.makeConstraints { make in
            make.top.equalTo(headerCollection.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    // 콜렉션 뷰 옵션
    private func configCollection() {
        capsuleCollection.delegate = self
        capsuleCollection.dataSource = self
        // 셀 등록
        capsuleCollection.register(LockedCapsuleCell.self, forCellWithReuseIdentifier: LockedCapsuleCell.identifier)
        capsuleCollection.isPagingEnabled = true // 페이징 활성화
        capsuleCollection.showsVerticalScrollIndicator = false // 수직 스크롤 인디케이터 표시 여부 설정.
        capsuleCollection.decelerationRate = .normal // 콜렉션 뷰의 감속 속도 설정
        capsuleCollection.alpha = 1 // 투명도
        if let layout = capsuleCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.collectionView?.isPagingEnabled = true
            layout.scrollDirection = .vertical // 스크롤 방향(수직)
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = screenWidth * 0.9 // 화면 너비의 90%를 아이템 너비로 설정
            let itemHeight: CGFloat = 230 // 아이템 높이는 고정 값으로 설정
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            // 섹션 여백 설정
            let sectionInsetHorizontal = screenWidth * 0.05 // 좌우 여백을 화면 너비의 5%로 설정
            layout.sectionInset = UIEdgeInsets(top: 10, left: sectionInsetHorizontal, bottom: 10, right: sectionInsetHorizontal)
            // 최소 줄 간격 설정
            let minimumLineSpacing = itemHeight * 0.1 // 최소 줄 간격을 화면 너비의 10%로 설정
            layout.minimumLineSpacing = minimumLineSpacing
            layout.sectionHeadersPinToVisibleBounds = true
        }
    }
                        // MARK: - 수정(03/18) 황주영
    // 데이터 정보 가져오기.
    private func fetchTimeCapsulesInfo() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: false)
            .order(by: "openTimeBoxDate", descending: false) // 가장 먼저 개봉될 타임캡슐부터 정렬
            .getDocuments { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                let timeBoxes = documents.compactMap { doc -> TimeBox? in
                    let data = doc.data()
                    guard let createTimeBoxDate = (data["createTimeBoxDate"] as? Timestamp)?.dateValue(),
                          let openTimeBoxDate = (data["openTimeBoxDate"] as? Timestamp)?.dateValue(),
                          let location = data["location"] as? GeoPoint? else {
                        return nil
                    }
                    return TimeBox(
                        id: doc.documentID,
                        uid: data["uid"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        thumbnailURL: data["thumbnailURL"] as? String,
                        imageURL: data["imageURL"] as? [String],
                        location: location,
                        addressTitle: data["addressTitle"] as? String ?? "",
                        address: data["address"] as? String ?? "",
                        description: data["description"] as? String,
                        tagFriendUid: data["tagFriendUid"] as? [String],
                        createTimeBoxDate: Timestamp(date: (createTimeBoxDate)),
                        openTimeBoxDate: Timestamp(date: (openTimeBoxDate)),
                        isOpened: data["isOpened"] as? Bool ?? false
                    )
                }
                
                print("Fetched \(timeBoxes.count) timeboxes for userID: \(userId)")
                
                DispatchQueue.main.async {
                    self?.timeBoxes = timeBoxes // 'self?.timeBoxes'는 TimeBox 객체들을 저장하는 프로퍼티
                    print("collectionView reload.")
                    self?.capsuleCollection.reloadData()
                }
            }
    }
}

extension CustomModal: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeBoxes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LockedCapsuleCell.identifier, for: indexPath) as? LockedCapsuleCell else {
            fatalError("Unable to dequeue LockedCapsuleCell")
        }
        
        let timeBoxes = timeBoxes[indexPath.row]
        cell.configure(with: timeBoxes)
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCapsule = timeBoxes[indexPath.row]
        // 'selectedCapsule.userLocation'이 'GeoPoint?' 타입이므로, 옵셔널 체이닝과 옵셔널 바인딩을 사용하여 안전하게 처리
        if let latitude = selectedCapsule.location?.latitude, let longitude = selectedCapsule.location?.longitude {
            onCapsuleSelected?(latitude, longitude)
        }
    }
}



