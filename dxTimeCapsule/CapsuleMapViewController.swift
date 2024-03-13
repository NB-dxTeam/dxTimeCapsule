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
import FirebaseFirestore

class CapsuleMapViewController: UIViewController {
    
    private let capsuleMaps = MKMapView() // 지도 뷰
    var locationManager = CLLocationManager()
    var currentDetent: String? = nil
    
    // 원래 지도의 중심 위치를 저장할 변수
    private var originalCenterCoordinate: CLLocationCoordinate2D?
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    private lazy var backView: UIView = {
        let backView = UIView()
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10
        backView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        return backView
    }()
    private lazy var tapDidModal: UIButton = {
        let button = UIButton()
        // "listicon" 이름의 이미지로 버튼의 아이콘 설정
        button.setBackgroundImage(UIImage(named: "listicon"), for: .normal)
//        button.layer.masksToBounds = true
//        button.layer.cornerRadius = 10
        // 버튼이 탭 되었을 때 실행될 액션 추가
        button.addTarget(self, action: #selector(modalButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "locationicon"), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2
        button.addTarget(self, action: #selector(locationButton(_:)), for: .touchUpInside)
        return button
    }()// 현재 위치로
    private let zoomInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "plusicon02"), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        return button
    }()
    
    private let zoomOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "minusicon02"), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        button.setTitleColor(.black, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        return button
    }()
    
    private lazy var zoomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [zoomInButton, zoomOutButton])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        setupStackView()
        autoLayouts()
        locationSetting()
        showModalVC()
        setupMapView()
        buttons()
        loadCapsuleInfos()
        tapDidModal.setBlurryBeach()
//        addLogoToNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tapDidModal.setBlurryBeach()
//        currentLocationBotton.setBlurryBeach()
    }
    
    private func addLogoToNavigationBar() {
        // 로고 이미지 설정
        let logoImage = UIImage(named: "App_Logo")
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        
        // 이미지 뷰의 크기 설정
        let imageSize = CGSize(width: 120, height: 40) // 원하는 크기로 조절
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
        self.view.addSubview(currentLocationButton)
        self.view.addSubview(zoomStackView)
        capsuleMaps.addSubview(stackView)
    }
    private func setupStackView() {
        // 스택 뷰에 버튼과 배경 뷰를 추가
        stackView.addArrangedSubview(backView)
        backView.addSubview(tapDidModal)
    }
    private func autoLayouts() {
        capsuleMaps.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(capsuleMaps.snp.bottom).offset(-10)
            make.trailing.equalTo(capsuleMaps.snp.trailing).offset(-10)
            make.width.equalTo(capsuleMaps.snp.width).multipliedBy(0.1) // 맵 뷰의 너비에 따라 조정
            make.height.equalTo(40) // backView의 높이를 지정합니다.
        }
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tapDidModal.snp.makeConstraints { make in
            make.center.equalToSuperview() // backView의 중심에 배치
            make.size.equalTo(CGSize(width: 20, height: 20)) // 버튼의 크기를 설정합니다.
        }
        currentLocationButton.snp.makeConstraints { make in
            make.top.equalTo(capsuleMaps.snp.top).offset(10)
            make.trailing.equalTo(capsuleMaps.snp.trailing).offset(-5)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        zoomStackView.snp.makeConstraints { make in
            make.trailing.equalTo(capsuleMaps.snp.trailing).offset(-5)
            make.centerY.equalTo(capsuleMaps.snp.centerY)
            make.width.equalTo(30)
        }
    }
    private func buttons() {
        tapDidModal.addTarget(self, action: #selector(modalButton(_:)), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(locationButton(_:)), for: .touchUpInside)
        
    }
    // MARK: - Actions for zoom buttons
    @objc private func zoomIn() {
        let region = MKCoordinateRegion(center: capsuleMaps.centerCoordinate, span: capsuleMaps.region.span)
        let zoomedRegion = capsuleMaps.regionThatFits(MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2, longitudeDelta: region.span.longitudeDelta / 2)))
        capsuleMaps.setRegion(zoomedRegion, animated: true)
    }
    
    @objc private func zoomOut() {
        let region = MKCoordinateRegion(center: capsuleMaps.centerCoordinate, span: capsuleMaps.region.span)
        let zoomedRegion = capsuleMaps.regionThatFits(MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2, longitudeDelta: region.span.longitudeDelta * 2)))
        capsuleMaps.setRegion(zoomedRegion, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension CapsuleMapViewController: CLLocationManagerDelegate {
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
                DispatchQueue.main.async {
                    self?.showLoadFailureAlert(withError: error!)
                }
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
            let annotation = CapsuleAnnotationModel(coordinate: coordinate, title: capsule.userLocation, subtitle: "개봉일: \(capsule.openTimeCapsuleDate)", info: capsule)
            self.capsuleMaps.addAnnotation(annotation)
        }
        print("지도에 \(capsules.count)개의 어노테이션이 추가되었습니다.")
    }
}

extension CapsuleMapViewController {
    // CustomModal 뷰를 모달로 화면에 표시하는 함수
    func showModalVC() {
        let vc = CustomModal()
        //vc.sheetPresentationController?.delegate = self
        // CustomModal에서 타임캡슐 선택 시 실행할 클로저 구현
        vc.onCapsuleSelected = { [weak self] latitude, longitude in
            // 지도의 위치를 업데이트하는 메소드 호출
            self?.moveToLocation(latitude: latitude, longitude: longitude)
            
            if let sheet = vc.sheetPresentationController {
                DispatchQueue.main.async {
                    sheet.animateChanges {
                        sheet.detents = [.half, .large()]
                        sheet.selectedDetentIdentifier = .half
                        sheet.largestUndimmedDetentIdentifier = .large
                    }
                }
            }
            
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.half, .large()] // 크기 옵션
            sheet.prefersGrabberVisible = true // 모달의 상단 그랩 핸들러 표시 여부
            // 스크롤 가능한 내영이 모달 끝에 도달했을 때 스크롤 확장 여부
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            // 어둡지 않게 표시되는 최대 크기의 상태 설정
            sheet.largestUndimmedDetentIdentifier = .large
        }
        
        self.present(vc, animated: true)
    }
    
    func moveToLocation(latitude: Double, longitude: Double) {
        var adjustedLatitude = latitude
        var adjustedLongitude = longitude
        
        let location = CLLocationCoordinate2D(latitude: adjustedLatitude, longitude: adjustedLongitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000) // 셀 탭했을 때, 줌 상태
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
        capsuleMaps.showsCompass = false
        
        // 위치 사용 시 사용자의 현재 위치 표시
        capsuleMaps.showsUserLocation = true
        capsuleMaps.layer.masksToBounds = true
        capsuleMaps.layer.cornerRadius = 10
        
        // 애니메이션 효과가 추가 되어 부드럽게 화면 확대 및 이동
        //capsuleMaps.setUserTrackingMode(.follow, animated: true)
        capsuleMaps.setUserTrackingMode(.followWithHeading, animated: true)
       
        let initalLocation = CLLocation(latitude: 35.9333, longitude: 127.9933)
        let regionRadius: CLLocationDistance = 400000
        let coordinateRegion = MKCoordinateRegion(center: initalLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        capsuleMaps.setRegion(coordinateRegion, animated: true)
    }
    
    // 지도를 스크롤 및 확대할 때, 호출 됨. 즉, 지도 영역이 변경될 때 호출
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("지도 위치 변경")
    }
    
    // 사용자 위치가 업데이트 될 때, 호출 ( 캡슐 셀 텝 동작시 해당지역 확대 로직 여기에 추가)
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        capsuleMaps.setRegion(region, animated: true)
//    }
    
    
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
            //annotationView?.markerTintColor = .purple // 마커 색상 변경
            annotationView?.glyphText = "🎁" // 마커에 표시 될 이미지
            annotationView?.titleVisibility = .adaptive // 제목 가시성 설정
            annotationView?.subtitleVisibility = .adaptive // 부제목 가시성 설정
        } else {
            annotationView?.annotation = annotation
        }

        // 추가적인 커스터마이징이 필요한 경우 여기에 코드를 추가
        annotationView?.glyphText = "🎁"
        annotationView?.canShowCallout = true
        annotationView?.animatesWhenAdded = true
        annotationView?.titleVisibility = .adaptive // 제목 가시성 설정
        annotationView?.subtitleVisibility = .adaptive // 부제목 가시성 설정
        return annotationView
    }
    
}

// MARK: - UISheetPresentationControllerDelegate
extension CapsuleMapViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        guard let detentIdentifier = sheetPresentationController.selectedDetentIdentifier else {
            return
        }
       
    }
}
// MARK: - Preview
//import SwiftUI
//import FirebaseFirestoreInternal
//
//struct Preview: PreviewProvider {
//    static var previews: some View {
//        CapsuleMapViewController().toPreview()
//    }
//}
//
//#if DEBUG
//extension UIViewController {
//    private struct Preview: UIViewControllerRepresentable {
//            let viewController: UIViewController
//            func makeUIViewController(context: Context) -> UIViewController {
//                return viewController
//            }
//            func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//            }
//        }
//        func toPreview() -> some View {
//            Preview(viewController: self)
//        }
//}
//#endif
