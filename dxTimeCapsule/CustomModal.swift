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
    
    var capsuleInfo = [CapsuleInfo]()
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
        collection.backgroundColor = .red
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
            let minimumLineSpacing = itemHeight * 0.2 // 최소 줄 간격을 화면 너비의 10%로 설정
            layout.minimumLineSpacing = 20
            layout.sectionHeadersPinToVisibleBounds = true
        }
    }
    // 데이터 정보 가져오기.
    private func fetchTimeCapsulesInfo() {
        let db = Firestore.firestore()
        let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2" // Example UID, replace with dynamic UID
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: false) // 아직 열리지 않은 타임캡슐만 선택
            .order(by: "openDate", descending: false) // 가장 먼저 개봉될 타임캡슐부터 정렬
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    print("documents 개수: \(documents.count)")
                    self?.capsuleInfo = documents.compactMap { doc in
                        let data = doc.data()
                        let capsule = CapsuleInfo(
                            TimeCapsuleId: doc.documentID,
                            tcBoxImageURL: data["tcBoxImageURL"] as? String,
                            latitude: data["latitude"] as? Double ?? 37.5115,
                            longitude: data["longitude"] as? Double ?? 127.0986,
                            userLocation: data["userLocation"] as? String,
                            userComment: data["userComment"] as? String,
                            createTimeCapsuleDate: (data["creationDate"] as? Timestamp)?.dateValue() ?? Date(),
                            openTimeCapsuleDate: (data["openDate"] as? Timestamp)?.dateValue() ?? Date(),
                            isOpened: data["isOpened"] as? Bool ?? false
                        )
                        print("매핑된 캡슐: \(capsule)")
                        return capsule
                    }
                    print("Fetching time capsules for userID: \(userId)")
                    print("Fetched \(self?.capsuleInfo.count ?? 0) timecapsules")
                    
                    DispatchQueue.main.async {
                        print("collectionView reload.")
                        self?.capsuleCollection.reloadData()
                    }
                } else if let err = err {
                    print("Error getting documents: \(err)")
                    DispatchQueue.main.async {
                        self?.showLoadFailureAlert(withError: err)
                    }
                }
            }
    }
}

extension CustomModal: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capsuleInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LockedCapsuleCell.identifier, for: indexPath) as? LockedCapsuleCell else {
            fatalError("Unable to dequeue LockedCapsuleCell")
        }
        
        let capsuleInfo = capsuleInfo[indexPath.row]
        cell.configure(with: capsuleInfo)
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCapsule = capsuleInfo[indexPath.row]
        onCapsuleSelected?(selectedCapsule.latitude, selectedCapsule.longitude)
    }
}


import SwiftUI

struct PreView: PreviewProvider {
    static var previews: some View {
        CustomModal().toPreview()
    }
}
