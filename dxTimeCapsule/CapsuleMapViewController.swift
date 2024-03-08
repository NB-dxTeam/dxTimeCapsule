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
    var currentDetent: String? = nil
    // 원래 지도의 중심 위치를 저장할 변수
    private var originalCenterCoordinate: CLLocationCoordinate2D?
    
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
        addLogoToNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tapDidModal.setBlurryBeach()
        currentLocationBotton.setBlurryBeach()
    }
    
    private func addLogoToNavigationBar() {
        // 로고 이미지 설정
        let logoImage = UIImage(named: "App_Logo")
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        
        // 이미지 뷰의 크기 설정
        let imageSize = CGSize(width: 150, height: 45) // 원하는 크기로 조절
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize) // x값을 0으로 변경하여 왼쪽 상단에 위치하도록 설정
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        containerView.addSubview(imageView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
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
    
    // 데이터 정보 불러오기
    func loadCapsuleInfos() {
        let db =  Firestore.firestore()
        let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2"
        
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: false) // 아직 열리지 않은 타임캡슐만 선택
            .order(by: "openDate", descending: false) // 가장 먼저 개봉될 타임캡슐부터 정렬
            .getDocuments { [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            let capsules = documents.map { doc -> CapsuleInfo in
                let data = doc.data()
                let capsule = CapsuleInfo(
                    TimeCapsuleId: doc.documentID,
                    tcBoxImageURL: data["tcBoxImageURL"] as? String,
                    latitude: data["latitude"] as? Double ?? 0,
                    longitude: data["longitude"] as? Double ?? 0,
                    userLocation: data["userLocation"] as? String,
                    userComment: data["userComment"] as? String,
                    createTimeCapsuleDate: (data["creationDate"] as? Timestamp)?.dateValue() ?? Date(),
                    openTimeCapsuleDate: (data["openDate"] as? Timestamp)?.dateValue() ?? Date(),
                    isOpened: data["isOpened"] as? Bool ?? false
                )
                print("Loaded capsule: \(capsule.TimeCapsuleId) at [Lat: \(capsule.latitude), Long: \(capsule.longitude)]")
                return capsule
            }
                self?.addAnnotations(from: capsules)
        }
    }
    
    // 타임캡슐 정보를 기반으로 어노테이션 추가
    func addAnnotations(from capsules: [CapsuleInfo]) {
        for capsule in capsules {
            let coordinate = CLLocationCoordinate2D(latitude: capsule.latitude, longitude: capsule.longitude)
            let annotation = CapsuleAnnotation(coordinate: coordinate, title: capsule.userLocation, subtitle: "개봉일: \(capsule.openTimeCapsuleDate)", info: capsule)
            self.capsuleMaps.addAnnotation(annotation)
        }
        print("지도에 \(capsules.count)개의 어노테이션이 추가되었습니다.")
    }
}

extension CapsuleMapViewController {
    // CustomModal 뷰를 모달로 화면에 표시하는 함수
    func showModalVC() {
        let vc = CustomModal()
        vc.sheetPresentationController?.delegate = self
        // CustomModal에서 타임캡슐 선택 시 실행할 클로저 구현
        vc.onCapsuleSelected = { [weak self] latitude, longitude in
            // 지도의 위치를 업데이트하는 메소드 호출
            self?.moveToLocation(latitude: latitude, longitude: longitude)
        }
        
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
    
    func moveToLocation(latitude: Double, longitude: Double, adjustForModal: Bool = true) {
        var adjustedLatitude = latitude
        var adjustedLongitude = longitude
        
        // 모달 상태가 .medium일 때만 위치 조정
        if adjustForModal && currentDetent == "medium" {
            // 지도의 중심을 적절히 조정하는 로직
            // 예: 위도를 조금 더 높여서(북쪽으로) 지도 중심을 올립니다.
            adjustedLatitude -= 0.002 // 조정 값은 상황에 맞게 변경해야 합니다.
        }
        
        let location = CLLocationCoordinate2D(latitude: adjustedLatitude, longitude: adjustedLongitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        capsuleMaps.setRegion(region, animated: true)
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
            annotationView?.glyphImage = UIImage(named: "TimeCapsule") // 마커에 표시 될 이미지
            annotationView?.titleVisibility = .adaptive // 제목 가시성 설정
            annotationView?.subtitleVisibility = .adaptive // 부제목 가시성 설정
        } else {
            annotationView?.annotation = annotation
        }

        // 추가적인 커스터마이징이 필요한 경우 여기에 코드를 추가
        annotationView?.glyphImage = UIImage(named: "TimeCapsule")
        annotationView?.canShowCallout = true
        annotationView?.animatesWhenAdded = true
        return annotationView
    }
    
}

// MARK: - UISheetPresentationControllerDelegate
extension CapsuleMapViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        guard let detentIdentifier = sheetPresentationController.selectedDetentIdentifier else {
            return
        }
        let centerCoordinate = capsuleMaps.centerCoordinate
        
        switch detentIdentifier {
        case .medium:
            if originalCenterCoordinate == nil { // 원래 위치가 저장되지 않았다면 현재 보고 있는 지도의 중심을 저장
                originalCenterCoordinate = capsuleMaps.centerCoordinate
            }
            // 중심 조정 로직
            let adjustedCenter = CLLocationCoordinate2D(latitude: centerCoordinate.latitude - 0.002, longitude: centerCoordinate.longitude)
            let adjustedRegion = MKCoordinateRegion(center: adjustedCenter, latitudinalMeters: 500, longitudinalMeters: 500)
            capsuleMaps.setRegion(adjustedRegion, animated: true)
        default:
            // 다른 상태로 변경될 때 원래 위치로 되돌림
            if let originalCenter = originalCenterCoordinate {
                let originalRegion = MKCoordinateRegion(center: originalCenter, latitudinalMeters: 500, longitudinalMeters: 500)
                capsuleMaps.setRegion(originalRegion, animated: true)
                originalCenterCoordinate = nil // 사용 후 리셋
            }
        }
    }
}
// MARK: - Preview
import SwiftUI
import FirebaseFirestoreInternal

struct PreView: PreviewProvider {
    static var previews: some View {
        MainTabBarView().toPreview()
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
