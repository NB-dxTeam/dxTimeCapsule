//
//  CapsuleMapVC+Extensions.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/19/24.
//

import UIKit
import MapKit
import SnapKit


extension CapsuleMapViewController {
    
    func configureDetailView(for annotation: TimeBoxAnnotation) -> UIView {
        self.selectedTimeBoxAnnotationData = annotation.timeBoxAnnotationData
        let timeBoxData = annotation.timeBoxAnnotationData
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd" // 날짜 형식 지정
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대 설정
        dateFormatter.locale = Locale(identifier: "ko_KR") // 로케일을 한국어로 설정
        
        if let locationTitle = timeBoxData?.timeBox.addressTitle {
            let titleLabel = UILabel()
            titleLabel.text = locationTitle
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            stackView.addArrangedSubview(titleLabel)
        }
        let createTimetitle = UILabel()
        createTimetitle.text = "생성일"
        createTimetitle.textColor = .gray.withAlphaComponent(0.8)
        createTimetitle.font = UIFont.systemFont(ofSize: 12)
        createTimetitle.textAlignment = .left
        
        let createTimeStackView = UIStackView()
        createTimeStackView.axis = .horizontal
        createTimeStackView.spacing = 8
        createTimeStackView.addArrangedSubview(createTimetitle)
        
        if let createTime = timeBoxData?.timeBox.createTimeBoxDate?.dateValue() {
            let createDateLabel = UILabel()
            createDateLabel.text = dateFormatter.string(from: createTime)
            createDateLabel.font = UIFont.systemFont(ofSize: 16)
            createTimeStackView.addArrangedSubview(createDateLabel)
        }
        
        // createTimeStackView를 stackView에 추가
        stackView.addArrangedSubview(createTimeStackView)
        
        let openTimetitle = UILabel()
        openTimetitle.text = "개봉일"
        openTimetitle.font = UIFont.systemFont(ofSize: 12)
        openTimetitle.textAlignment = .left
        openTimetitle.textColor = .gray.withAlphaComponent(0.8)
        
        let openTimeStackView = UIStackView()
        openTimeStackView.axis = .horizontal
        openTimeStackView.spacing = 8
        openTimeStackView.addArrangedSubview(openTimetitle)
        
        if let openTime = timeBoxData?.timeBox.openTimeBoxDate?.dateValue() {
            let openDateLabel = UILabel()
            openDateLabel.text = dateFormatter.string(from: openTime)
            openDateLabel.font = UIFont.systemFont(ofSize: 16)
            openTimeStackView.addArrangedSubview(openDateLabel)
        }
        
        // openTimeStackView를 stackView에 추가
        stackView.addArrangedSubview(openTimeStackView)
        
        if let friends = timeBoxData?.friendsInfo, !friends.isEmpty {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 70, height: 100)
            //let friendsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            friendsCollectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: "FriendCollectionViewCell")
            friendsCollectionView.dataSource = self
            friendsCollectionView.delegate = self
            friendsCollectionView.showsHorizontalScrollIndicator = false
            stackView.addArrangedSubview(friendsCollectionView)
            
            friendsCollectionView.snp.makeConstraints { make in
                make.height.equalTo(80)
                make.leading.trailing.equalToSuperview()
            }
        }
        
        let detailView = UIView()
        detailView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
        detailView.snp.makeConstraints { make in
            make.width.equalTo(150)
        }
        DispatchQueue.main.async {
            self.friendsCollectionView.reloadData()
        }
        
        print("Detail view constructed and configured")
        return detailView
    }
    
    func addAnnotations(from timeBoxes: [TimeBox]) {
        print("addAnnotations 호출됨, 처리할 timeBoxes의 수: \(timeBoxes.count)")
        capsuleMaps.removeAnnotations(capsuleMaps.annotations) // 기존 어노테이션 제거
        
        let allTaggedFriendUids = Set(timeBoxes.compactMap({ $0.tagFriendUid }).flatMap({ $0 }))
                
        // 친구 정보 가져오기.
        FirestoreDataService().fetchFriendsInfo(byUIDs: Array(allTaggedFriendUids)) { [weak self] friendsInfo in
            guard let friendsInfo = friendsInfo else { return }
            
            // uid로 친구 정보 빠르게 검색하기.
            let friendsLookup = Dictionary(uniqueKeysWithValues: friendsInfo.map { ($0.uid, $0) })
            
            DispatchQueue.main.async {
                for timeBox in timeBoxes {
                    guard let location = timeBox.location else { continue }
                    print("Creating annotation for TimeBox with ID: \(timeBox.tagFriendUid ?? []) at location: \(location.latitude), \(location.longitude)")
                    let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    let friendsInfo = timeBox.tagFriendUid?.compactMap { friendsLookup[$0] } ?? []
                    let annotationData = TimeBoxAnnotationData(timeBox: timeBox, friendsInfo: friendsInfo)
                    let annotation = TimeBoxAnnotation(coordinate: coordinate, timeBoxAnnotationData: annotationData)
                    
                    self?.capsuleMaps.addAnnotation(annotation)
                }
            }
        }
    }
}
