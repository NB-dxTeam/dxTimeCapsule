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
    // 타임박스 정보와 태그된 친구들의 정보를 담을 배열
    var timeBoxAnnotationsData = [TimeBoxAnnotationData]()
    // 원래 지도의 중심 위치를 저장할 변수
    private var originalCenterCoordinate: CLLocationCoordinate2D?
    private var shouldShowModal = false
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
        
        return button
    }()
    
    private let zoomOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "minusicon02"), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        button.setTitleColor(.black, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
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
        setupMapView()
        buttons()
        loadCapsuleInfos()
        tapDidModal.setBlurryBeach()
//        addLogoToNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowModal {
            showModalVC()
        }
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
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
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
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
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
        
        // 로그인한 사용자의 UID를 가져옵니다.
        //        guard let userId = Auth.auth().currentUser?.uid else { return }
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
                
                var timeBoxes = [TimeBox]()
                let group = DispatchGroup()
                
                for doc in documents {
                    let data = doc.data()
                    let geoPoint = data["userLocation"] as? GeoPoint
                    var timeBox = TimeBox(
                        id: doc.documentID,
                        uid: data["uid"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        imageURL: data["imageURL"] as? [String],
                        userLocation: geoPoint,
                        userLocationTitle: data["userLocationTitle"] as? String,
                        description: data["description"] as? String,
                        tagFriendUid: data["tagFriendUid"] as? [String],
                        createTimeBoxDate: Timestamp(date: (data["createTimeBoxDate"] as? Timestamp)?.dateValue() ?? Date()),
                        openTimeBoxDate: Timestamp(date: (data["openTimeBoxDate"] as? Timestamp)?.dateValue() ?? Date()),
                        isOpened: data["isOpened"] as? Bool ?? false
                    )
                    
                    if let tagFriendUids = timeBox.tagFriendUid, !tagFriendUids.isEmpty {
                        group.enter()
                        FirestoreDataService().fetchFriendsInfo(byUIDs: tagFriendUids) { [weak self] friendsInfo in
                            guard let friendsInfo = friendsInfo else {
                                group.leave()
                                return
                            }
                            
                            // 타임박스와 관련된 친구 정보를 포함하는 어노테이션 데이터를 생성
                            let annotationData = TimeBoxAnnotationData(timeBox: timeBox, friendsInfo: friendsInfo)
                            self?.timeBoxAnnotationsData.append(annotationData)
                            
                            group.leave()
                        }
                    }
                    timeBoxes.append(timeBox)
                }
                
                group.notify(queue: .main) {
                    // 모든 타임박스 데이터 처리 완료 후 UI 업데이트 로직 구현 필요
                    self?.addAnnotations(from: timeBoxes)
                }
            }
    }
    
    // 타임캡슐 정보를 기반으로 어노테이션 추가
    func addAnnotations(from timeBoxes: [TimeBox]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd" // 날짜 형식 지정
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대 설정
        dateFormatter.locale = Locale(identifier: "ko_KR") // 로케일을 한국어로 설정
        
        for timeBox in timeBoxes {
            guard let userLocation = timeBox.userLocation else { continue }
            let coordinate = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            // Firestore에서 가져온 날짜를 한국 시간대에 맞춰 형식화
            let formattedCreateDate = dateFormatter.string(from: timeBox.createTimeBoxDate.dateValue())
            let weekday = Calendar.current.component(.weekday, from: timeBox.createTimeBoxDate.dateValue())
            let weekdaySymbol = dateFormatter.weekdaySymbols[weekday - 1] // 요일 계산
            
            // FirestoreDataService 또는 비슷한 서비스를 사용하여 친구 정보 가져오기
            FirestoreDataService().fetchFriendsInfo(byUIDs: timeBox.tagFriendUid ?? []) { [weak self] friends in
                // 비동기적으로 친구 정보가 로드된 후에 어노테이션 생성
                DispatchQueue.main.async {
                    // 'friends' 배열을 직접 'CapsuleAnnotationModel'에 전달
                    let annotation = CapsuleAnnotationModel(
                        coordinate: coordinate,
                        title: timeBox.userLocationTitle,
                        subtitle: "등록한 날짜: \(formattedCreateDate) (\(weekdaySymbol))",
                        info: timeBox, // 이 부분은 TimeBox 모델로 직접 관련 데이터를 넣어주거나 필요한 데이터만 넣어줄 수 있습니다.
                        friends: friends // 여기에서 'friends' 타입이 [Friend]?와 일치하도록 수정됨
                    )
                    
                    self?.capsuleMaps.addAnnotation(annotation)
                }
            }
        }
        print("지도에 \(timeBoxes.count)개의 어노테이션이 추가되었습니다.")
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
        //vc.isModalInPresentation = true
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true)
    }
    
    func moveToLocation(latitude: Double, longitude: Double) {
        let adjustedLatitude = latitude
        let adjustedLongitude = longitude
        
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
    
    // 어노테이션 설정
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 사용자의 현재 위치 어노테이션은 기본 뷰를 사용
        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "CapsuleAnnotation"
        var annotationView: MKAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
            dequeuedView.canShowCallout = true
            dequeuedView.animatesWhenAdded = true
            dequeuedView.markerTintColor = .red
            dequeuedView.glyphImage = UIImage(named: "boximage1")
            //dequeuedView.glyphTintColor = .
        } else {
            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            markerView.canShowCallout = true // 콜아웃 표시 설정
            markerView.markerTintColor = .red // 마커 색상 설정
            //markerView.glyphText = "🎁" // 마커 내 표시될 텍스트 설정
            markerView.animatesWhenAdded = true
            markerView.glyphImage = UIImage(named: "boximage1")
            // 커스텀 콜아웃 뷰를 생성 및 설정
            let calloutView = CustomCalloutView()
            calloutView.translatesAutoresizingMaskIntoConstraints = false
            markerView.detailCalloutAccessoryView = calloutView // 콜아웃 뷰 지정
            
//            // 오른쪽 액세서리 뷰에 버튼 추가
//            let rightButton = UIButton(type: .detailDisclosure)
//            markerView.rightCalloutAccessoryView = rightButton
            
            annotationView = markerView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let capsuleAnnotation = view.annotation as? CapsuleAnnotationModel else { return }

        // 이전에 추가된 콜아웃 뷰를 제거
       // view.subviews.forEach { $0.removeFromSuperview() }

        let calloutView = CustomCalloutView()
        calloutView.configure(with: capsuleAnnotation.info, friends: capsuleAnnotation.friends)
        view.addSubview(calloutView)

        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
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
import SwiftUI
import FirebaseFirestoreInternal
//
//struct Preview: PreviewProvider {
//    static var previews: some View {
//        CapsuleMapViewController().toPreview()
//    }
//}

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
