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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        autoLayouts()
        locationSetting()
        showModalVC()
        setupMapView()
        buttons()
        loadCapsuleInfos()
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
    
    func loadCapsuleInfos() {
        Firestore.firestore().collection("capsules").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            let capsules = documents.map { doc -> CapsuleInfo in
                let data = doc.data()
                return CapsuleInfo(
                    TimeCapsuleId: doc.documentID,
                    tcBoxImageURL: data["tcBoxImageURL"] as? String,
                    latitude: data["latitude"] as? Double ?? 0,
                    longitude: data["longitude"] as? Double ?? 0,
                    userLocation: data["userLocation"] as? String,
                    userComment: data["userComment"] as? String,
                    createTimeCapsuleDate: (data["createTimeCapsuleDate"] as? Timestamp)?.dateValue() ?? Date(),
                    openTimeCapsuleDate: (data["openTimeCapsuleDate"] as? Timestamp)?.dateValue() ?? Date(),
                    isOpened: data["isOpened"] as? Bool ?? false
                )
            }
            self.addAnnotations(from: capsules)
        }
    }
    
    // 타임캡슐 정보를 기반으로 어노테이션 추가
    func addAnnotations(from capsules: [CapsuleInfo]) {
        for capsule in capsules {
            let coordinate = CLLocationCoordinate2D(latitude: capsule.latitude, longitude: capsule.longitude)
            let annotation = CapsuleAnnotation(coordinate: coordinate, title: capsule.userLocation, subtitle: "개봉일: \(capsule.openTimeCapsuleDate)", info: capsule)
            self.capsuleMaps.addAnnotation(annotation)
        }
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
    
}

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
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        capsuleMaps.setRegion(region, animated: true)
    }
    
    
    // 어노테이션 설정
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 사용자의 현재 위치 어노테이션은 기본 뷰를 사용
        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "CapsuleAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true // 호출 아웃 사용 설정
            annotationView?.markerTintColor = .purple // 마커 색상 변경
            annotationView?.glyphText = "🕰" // 마커 중앙에 표시될 텍스트 (예: 시계 이모지)
            annotationView?.titleVisibility = .adaptive // 제목 가시성 설정
            annotationView?.subtitleVisibility = .adaptive // 부제목 가시성 설정
        } else {
            annotationView?.annotation = annotation
        }

        // 추가적인 커스터마이징이 필요한 경우 여기에 코드를 추가합니다.
        // 예를 들어, 커스텀 이미지를 설정하려면:
        annotationView?.glyphImage = UIImage(named: "TimeCapsule")

        return annotationView
    }
    
}

// MARK: - Preview
import SwiftUI
import FirebaseFirestoreInternal

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
