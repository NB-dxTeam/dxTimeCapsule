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
    var capsuleMapViewController = CapsuleMapViewController()
    var onCapsuleSelected: ((Double, Double) -> Void)? //선택된 위치 정보를 받아 처리하는 클로저
    
    private var capsuleCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.layer.cornerRadius = 10
        collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
        print("capsuleCollection 인스턴스: \(Unmanaged.passUnretained(capsuleCollection).toOpaque())")
        view.backgroundColor = .white
        setupUI()
        configCollection()
        loadDataForStatus(.all)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCapsuleButtonTapped(notification:)), name: .capsuleButtonTapped, object: nil)
    }
    
    // addsubView, autolayout
    private func setupUI() {
        view.addSubview(capsuleCollection)


        capsuleCollection.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(UIScreen.main.bounds.height * 0.02)
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
        capsuleCollection.showsVerticalScrollIndicator = false // 수직 스크롤 인디케이터 표시 여부 설정.
        capsuleCollection.decelerationRate = .normal // 콜렉션 뷰의 감속 속도 설정
        capsuleCollection.alpha = 1 // 투명도
        if let layout = capsuleCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.collectionView?.isPagingEnabled = true
            layout.scrollDirection = .vertical // 스크롤 방향(수직)
            let screenWidth = UIScreen.main.bounds.width
            let itemHeight = CGFloat(UIScreen.main.bounds.height * 0.31)
            layout.itemSize = CGSize(width: screenWidth, height: itemHeight)
            // 섹션 여백 설정
            let sectionInsetHorizontal = screenWidth * 0.05 // 좌우 여백을 화면 너비의 5%로 설정
            layout.sectionInset = UIEdgeInsets(top: 0, left: sectionInsetHorizontal, bottom: 0, right: sectionInsetHorizontal)
            // 최소 줄 간격 설정
            let minimumLineSpacing = itemHeight * 0.1 // 최소 줄 간격을 화면 너비의 10%로 설정
            layout.minimumLineSpacing = minimumLineSpacing
            layout.sectionHeadersPinToVisibleBounds = true
            
        }
    }

    
    func dataCapsule(documents: [QueryDocumentSnapshot]) {
        let group = DispatchGroup()
        
        var tempTimeBoxes = [TimeBox]()
        var tempAnnotationsData = [TimeBoxAnnotationData]()
        
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
        self.timeBoxes = timeBoxes
        DispatchQueue.main.async {
            print("collectionView reload.")
            self.capsuleCollection.reloadData()
        }
    }
    
    func loadDataForStatus(_ status: CapsuleFilterButtons) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var query: Query
        switch status {
        case .all:
            query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
                .order(by: "openTimeBoxDate", descending: false)
            
        case .locked:
            query = db.collection("timeCapsules")
                .whereField("uid", isEqualTo: userId)
                .whereField("isOpened", isEqualTo: false)
        case .opened:
            query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
                .whereField("isOpened", isEqualTo: true)
        }
        print("전달 되는 필터: \(status)")
        query.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                // 에러가 있는 경우 여기서 처리합니다.
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                // documents가 없는 경우 처리
                print("No documents found")
                return
            }
            
            DispatchQueue.main.async {
                self?.dataCapsule(documents: documents)
            }
        }
    }
    
    @objc func handleCapsuleButtonTapped(notification: Notification) {
        guard let status = notification.userInfo?["status"] as? CapsuleFilterButtons else { return }
        loadDataForStatus(status)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CustomModal: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("timeBoxes 배열 갯수: \(timeBoxes.count)")
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



