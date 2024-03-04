//
//  CapsuleMapViewController.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit
import NMapsMap
import CoreLocation
import SnapKit

class CapsuleMapViewController: UIViewController {
    
    var timeCapsule = [TimeCapsule]()
//    let dummyTimeCapsules = [
//        TimeCapsule(timeCapsuleId: "1", uid: "user123", mood: "Happy", photoUrl: "SkyImage", location: "서울특별시 양천구 신월동", userLocation: "Namsan Tower", comment: "Great day!", tags: ["tag1", "tag2"], openDate: Date(), creationDate: Date()),
//        TimeCapsule(timeCapsuleId: "2", uid: "user124", mood: "Happy", photoUrl: "snow", location: "서울특별시 양천구 신월동", userLocation: "Namsan Tower", comment: "Great day!", tags: ["tag1", "tag2"], openDate: Date(), creationDate: Date()),
//        TimeCapsule(timeCapsuleId: "3", uid: "user124", mood: "Happy", photoUrl: "rain", location: "경기도 의정부시 의정부동", userLocation: "Namsan Tower", comment: "Great day!", tags: ["tag1", "tag2"], openDate: Date(), creationDate: Date()),
//    ]
    private lazy var capsuleMaps: NMFMapView = {
        let map = NMFMapView(frame: view.frame)
        return map
    }()
    private lazy var capsuleCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        //collection.backgroundColor = UIColor(red: 92/255, green: 177/255, blue: 255/255, alpha: 1.0)
        collection.layer.cornerRadius = 30
        collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collection.layer.masksToBounds = true
        return collection
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        autoLayouts()
        configCellection()
        shadowSettings()
    }
    
    
}

extension CapsuleMapViewController {
    private func configCellection() {
//        capsuleCollection.delegate = self
//        capsuleCollection.dataSource = self
        capsuleCollection.register(LockedCapsuleCell.self, forCellWithReuseIdentifier: LockedCapsuleCell.identifier)
        capsuleCollection.isPagingEnabled = true
        capsuleCollection.showsHorizontalScrollIndicator = false
        capsuleCollection.decelerationRate = .normal
        
        if let layout = capsuleCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal // 스크롤 방향(가로)
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = screenWidth * 0.9 // 화면 너비의 90%를 아이템 너비로 설정
            let itemHeight: CGFloat = 120 // 아이템 높이는 고정 값으로 설정
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            
            let sectionInsetHorizontal = screenWidth * 0.05 // 좌우 여백을 화면 너비의 5%로 설정
            layout.sectionInset = UIEdgeInsets(top: 48, left: sectionInsetHorizontal, bottom: 48, right: sectionInsetHorizontal)
            let minimumLineSpacing = screenWidth * 0.1 // 최소 줄 간격을 화면 너비의 10%로 설정
            layout.minimumLineSpacing = minimumLineSpacing
            
        }
        capsuleCollection.layer.borderWidth = 2.0 // 테두리 두께
        capsuleCollection.layer.borderColor = CGColor(red: 92/255, green: 177/255, blue: 255/255, alpha: 1.0)// 테두리 색상
    }
    
    private func shadowSettings() {
        capsuleCollection.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        capsuleCollection.layer.shadowOffset = CGSize(width: 0, height: 1) // 그림자 오프셋 설정
        capsuleCollection.layer.shadowRadius = 10.0 // 그림자 흐림 반경 설정
        capsuleCollection.layer.shadowOpacity = 0.5 // 그림자 불투명도
        capsuleCollection.layer.masksToBounds = false // 그림자 표시하려면 false 설정
        capsuleCollection.clipsToBounds = false // 경계 외부에 그림자 표시하려면 false 설정
    }
}

extension CapsuleMapViewController {
    private func addSubViews() {
        self.view.addSubview(capsuleMaps)
        self.view.addSubview(capsuleCollection)
    }
    
    private func autoLayouts() {
        capsuleMaps.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(capsuleCollection.snp.top).offset(30)
        }
        capsuleCollection.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(capsuleMaps.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(35)
            make.height.equalTo(350)
        }
        
    }
}
//
//extension CapsuleMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    /*func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {*/
//        return dummyTimeCapsules.count
//}
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LockedCapsuleCell.identifier, for: indexPath) as? LockedCapsuleCell else {
//            fatalError("Unable to dequeue LockedCapsuleCell")
//        }
//        let timeCapsule = dummyTimeCapsules[indexPath.item]
//        cell.registerImage.image = UIImage(named: timeCapsule.photoUrl ?? "placeholder")
//        cell.dayBadge.text = "D-\(daysUntilOpenDate(timeCapsule.openDate))"
//        cell.registerPlace.text = timeCapsule.location ?? ""
//        cell.registerDay.text = dateFormatter.string(from: timeCapsule.creationDate)
//        print("위치: \(timeCapsule.location ?? ""), 개봉일: \(timeCapsule.openDate), 등록일: \(timeCapsule.creationDate), 사용자 위치: \(timeCapsule.userLocation ?? "") ")
//        return cell
//    }
//    


extension CapsuleMapViewController {
    // D-Day 남은 일수 계산
    func daysUntilOpenDate(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
}



// MARK: - Preview
import SwiftUI

struct PreView: PreviewProvider {
    static var previews: some View {
        CapsuleMapViewController().toPreview()
    }
}

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif

