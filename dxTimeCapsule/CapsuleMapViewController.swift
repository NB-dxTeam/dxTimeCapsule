//
//  CapsuleMapViewController.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit

class CapsuleMapViewController: UIViewController, CLLocationManagerDelegate {
    

    private let capsuleMaps = MKMapView() // 지도 뷰
    var locationManager = CLLocationManager()
    private lazy var tapDidModal: UIButton = {
        let button = UIButton()
        button.setTitle("타임캡슐보기", for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(modalButton(_:)), for: .touchUpInside)
        return button
    }() // 모달 버튼
    private lazy var currentLocationBotton: UIButton = {
        let button = UIButton()
        button.setTitle("현재위치로", for: .normal)
        button.backgroundColor = .gray
        button.setTitleColor(.black, for: .normal)
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(locationButton(_:)), for: .touchUpInside)
        return button
    }()// 현재 위치로

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

 feat-MapPage
        locationSetting()
        showModalVC()
        setupMapView()
        buttons()

    }
    
}

extension CapsuleMapViewController {
    private func addSubViews() {
        self.view.addSubview(capsuleMaps)
        self.view.addSubview(tapDidModal)
        self.view.addSubview(currentLocationBotton)
    }
    
    private func autoLayouts() {
        capsuleMaps.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tapDidModal.snp.top)
        }
        currentLocationBotton.snp.makeConstraints { make in
            make.bottom.equalTo(capsuleMaps.snp.bottom).offset(-20)
            make.trailing.equalTo(capsuleMaps.snp.trailing).offset(-20)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        tapDidModal.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    private func buttons() {
        tapDidModal.addTarget(self, action: #selector(modalButton(_:)), for: .touchUpInside)
        currentLocationBotton.addTarget(self, action: #selector(locationButton(_:)), for: .touchUpInside)
    }
}

// MARK: - CLLocationManagerDelegate
extension CapsuleMapViewController {
    func locationSetting() {
        locationManager.delegate = self
        // 배터리에 맞게 권장되는 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 사용자 위치 권한 요청
        locationManager.requestWhenInUseAuthorization()
        // 위치 업데이트
        locationManager.startUpdatingLocation()
    }
    
    
}
extension CapsuleMapViewController {
    // CustomModal 뷰를 모달로 화면에 표시하는 함수
    func showModalVC() {
        let vc = CustomModal()
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.small ,.medium(), .large()] // 크기 옵션
            sheet.prefersGrabberVisible = true // 모달의 상단 그랩 핸들러 표시 여부
            // 스크롤 가능한 내영이 모달 끝에 도달했을 때 스크롤 확장 여부
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            // 어둡지 않게 표시되는 최대 크기의 상태 설정
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        self.present(vc, animated: true)
    }
    
    // 하프 모달 버튼 동작
    @objc func modalButton(_ sender: UIButton) {
        showModalVC()
    }
    // 지도 현재 위치로 이동
    @objc func locationButton(_ sender: UIButton) {
        capsuleMaps.setUserTrackingMode(.followWithHeading, animated: true)
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


// MARK: -MKMapViewDalegate
extension CapsuleMapViewController: MKMapViewDelegate {
    func setupMapView() {
        // 대리자를 뷰컨으로 설정
        capsuleMaps.delegate = self
        
        // 위치 사용 시 사용자의 현재 위치 표시
        capsuleMaps.showsUserLocation = true
        // 애니메이션 효과가 추가 되어 부드럽게 화면 확대 및 이동
        //capsuleMaps.setUserTrackingMode(.follow, animated: true)
        capsuleMaps.setUserTrackingMode(.followWithHeading, animated: true)
    }
    
    // 지도를 스크롤 및 확대할 때, 호출 됨. 즉, 지도 영역이 변경될 때 호출
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("지도 위치 변경")
    }
    
    // 사용자 위치가 업데이트 될 때, 호출 ( 캡슐 셀 텝 동작시 해당지역 확대 로직 여기에 추가)
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        capsuleMaps.setRegion(region, animated: true)
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
