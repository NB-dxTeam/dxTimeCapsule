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

struct TimeCapsules {
    var creationDate: Date
    var openDate: Date
    var userLocation: String
    var photoUrl: String
    var comment: String
}

class CustomModal: UIViewController {
    
    var timeCapsule = [TimeCapsules]()
    
    private var capsuleCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.layer.cornerRadius = 30
        collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collection.layer.masksToBounds = true
        return collection
    }()
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configCollection()
        fetchTimeCapsulesInfo()
    }
    // addsubView, autolayout
    private func setupUI() {
        view.addSubview(capsuleCollection)
        capsuleCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    // 콜렉션 뷰 옵션
    private func configCollection() {
        capsuleCollection.delegate = self
        capsuleCollection.dataSource = self
        // 셀 등록
        capsuleCollection.register(LockedCapsuleCell.self, forCellWithReuseIdentifier: LockedCapsuleCell.identifier)
        // 헤더 등록
        capsuleCollection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        capsuleCollection.isPagingEnabled = true // 페이징 활성화
        capsuleCollection.showsVerticalScrollIndicator = true // 수직 스크롤 인디케이터 표시 여부 설정.
        capsuleCollection.decelerationRate = .normal // 콜렉션 뷰의 감속 속도 설정
        capsuleCollection.alpha = 0.8
        if let layout = capsuleCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical // 스크롤 방향(수직)
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = screenWidth * 0.9 // 화면 너비의 90%를 아이템 너비로 설정
            let itemHeight: CGFloat = 250 // 아이템 높이는 고정 값으로 설정
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            // 섹션 여백 설정
            let sectionInsetHorizontal = screenWidth * 0.05 // 좌우 여백을 화면 너비의 5%로 설정
            layout.sectionInset = UIEdgeInsets(top: 24, left: sectionInsetHorizontal, bottom: 24, right: sectionInsetHorizontal)
            // 최소 줄 간격 설정
            let minimumLineSpacing = screenWidth * 0.1 // 최소 줄 간격을 화면 너비의 10%로 설정
            layout.minimumLineSpacing = minimumLineSpacing
            
        }
    }
    // 데이터 정보 가져오기.
    private func fetchTimeCapsulesInfo() {
        let db = Firestore.firestore()
        let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2" // Example UID, replace with dynamic UID
        
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    print("documents 개수: \(documents.count)")
                    self?.timeCapsule = documents.compactMap { doc in
                        let data = doc.data()
                        let capsule = TimeCapsules(
                            creationDate: data["creationDate"] as? Date ?? Date(),
                            openDate: data["openDate"] as? Date ?? Date(),
                            userLocation: data["userLocation"] as? String ?? "",
                            photoUrl: data["photoUrl"] as? String ?? "",
                            comment: data["comment"] as? String ?? ""
                        )
                        print("매핑된 캡슐: \(capsule)")
                        return capsule
                    }
                    print("Fetching time capsules for userID: \(userId)")
                    print("Fetched \(self?.timeCapsule.count ?? 0) timecapsules")
                    
                    DispatchQueue.main.async {
                        print("콜렉션 뷰 리로드.")
                        self?.capsuleCollection.reloadData()
                    }
                } else if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    print("문서 성공적으로 가져옴.")
                }
            }
    }
}

extension CustomModal: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeCapsule.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LockedCapsuleCell.identifier, for: indexPath) as? LockedCapsuleCell else {
            fatalError("Unable to dequeue LockedCapsuleCell")
        }
        
        let timeCapsule = timeCapsule[indexPath.row]
        cell.configure(with: timeCapsule)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        //headerView.sortButtonAction = { [weak self] in
        // 등록일순, D-day순, 거리순 로직 구현
        //}
        
        //collectionView.reloadData()
        headerView.headerLabel.text = "여기에 정렬 옵션 추가"
        return headerView
    }
}

extension CustomModal: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // 헤더 뷰의 크기 설정
        return CGSize(width: collectionView.frame.width, height: 48)
    }
}

extension CustomModal {
    // D-Day 남은 일수 계산
    func daysUntilOpenDate(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
}

// MARK: - CollectionView Header
class HeaderView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderView"
    
    // 정렬 버튼
//    private let sortCapsule: UIButton = {
//        let button = UIButton()
//        button.setTitle("등록일순", for: .normal)
//        return button
//    }()
    var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "여기에 정렬 옵션 추가"
        return label
    }()
    
    // 버튼 클로저
    var sortButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.top.equalTo(20)
            
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func didTapSortButton() {
//        sortButtonAction?()
//    }
}

