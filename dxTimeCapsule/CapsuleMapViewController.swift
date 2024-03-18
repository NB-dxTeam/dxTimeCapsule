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
import FirebaseAuth

class CapsuleMapViewController: UIViewController {
    
    private let capsuleMaps = MKMapView() // 지도 뷰
    var locationManager = CLLocationManager()
    var currentDetent: String? = nil
    // 타임박스 정보와 태그된 친구들의 정보를 담을 배열
    var timeBoxAnnotationsData = [TimeBoxAnnotationData]()
    // 원래 지도의 중심 위치를 저장할 변수
    private var originalCenterCoordinate: CLLocationCoordinate2D?
    private var shouldShowModal = false
    
    private lazy var aButton: UIButton = createRoundButton(title: "A")
    private lazy var bButton: UIButton = createRoundButton(title: "B")
    private lazy var cButton: UIButton = createRoundButton(title: "C")
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [aButton, bButton, cButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10 // 버튼 사이의 간격을 설정합니다.
        return stackView
    }()
    
    // 뒤로가기 버튼
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "arrowLeft"), for: .normal) // 시스템 아이콘을 사용합니다.
        return button
    }()
    // 하프모달 버튼
    private lazy var tapDidModal: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "list"), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 35
        return button
    }()
    // 현재 위치 버튼
    private lazy var currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "locationicon"), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        return button
    }()
    // 지도 확대 버튼
    private let zoomInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        return button
    }()
    // 줌 배경
    private let zoomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 20
        return view
    }()
    // 지도 축소 버튼
    private let zoomOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        setupZoomControls()
        autoLayouts()
        locationSetting()
        setupMapView()
        buttons()
        loadCapsuleInfos()
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
        self.view.addSubview(zoomBackgroundView)
        view.addSubview(backButton)
        view.addSubview(buttonsStackView)
    }
    private func setupZoomControls() {
        view.addSubview(zoomBackgroundView)
        zoomBackgroundView.addSubview(zoomInButton)
        zoomBackgroundView.addSubview(zoomOutButton)
    }
    private func autoLayouts() {
        capsuleMaps.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(40)
        }
        tapDidModal.snp.makeConstraints { make in
            make.bottom.equalTo(capsuleMaps.snp.bottom).offset(-20)
            make.trailing.equalTo(capsuleMaps.snp.trailing).offset(-20)
            make.size.equalTo(CGSize(width: 70, height: 70))
        }
        currentLocationButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(capsuleMaps.snp.trailing).offset(-10)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        zoomBackgroundView.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(-50) // 센터보다 위로 조금
            make.width.equalTo(40)
            make.height.equalTo(120)
        }
        
        zoomInButton.snp.makeConstraints { make in
            make.top.equalTo(zoomBackgroundView.snp.top).offset(10)
            make.centerX.equalTo(zoomBackgroundView.snp.centerX)
            make.width.equalTo(zoomBackgroundView.snp.width).multipliedBy(0.6)
            make.height.equalTo(zoomInButton.snp.width)
        }
        
        zoomOutButton.snp.makeConstraints { make in
            make.bottom.equalTo(zoomBackgroundView.snp.bottom).offset(-10)
            make.centerX.equalTo(zoomBackgroundView.snp.centerX)
            make.width.equalTo(zoomBackgroundView.snp.width).multipliedBy(0.6)
            make.height.equalTo(zoomOutButton.snp.width)
        }
    }
    private func buttons() {
        tapDidModal.addTarget(self, action: #selector(modalButton(_:)), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(locationButton(_:)), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    // MARK: - Actions
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
    private func createRoundButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white.withAlphaComponent(0.8) // 배경색을 설정합니다.
        button.layer.cornerRadius = 20 // 모서리를 둥글게 합니다.
        button.snp.makeConstraints { make in // SnapKit을 사용하여 제약조건을 설정합니다.
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
        // 버튼의 동작은 사용자가 정의할 수 있습니다.
        return button
    }
    // 뒤로가기 버튼 동작
    @objc private func backButtonTapped() {
        if let presentedVC = presentedViewController, presentedVC is CustomModal {
            presentedVC.dismiss(animated: true) { [weak self] in
                self?.tabBarController?.selectedIndex = 0
            }
        } else {
            self.tabBarController?.selectedIndex = 0
        }
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
        guard let userId = Auth.auth().currentUser?.uid else { return }
        //let userId = "FNZgZFdLTXXjOkbJY841BW1WhAB2"
        print("Starting to load time capsule infos for user \(userId)") // 문서로드시작
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .order(by: "openDate", descending: true) // 가장 먼저 개봉될 타임캡슐부터 정렬
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
//                    DispatchQueue.main.async {
//                        self?.showLoadFailureAlert(withError: error!)
//                    }
                    return
                }
                print("Successfully fetched \(documents.count) documents") // 문서로드 성공 및 문서 수
                var timeBoxes = [TimeBox]()
                let group = DispatchGroup()
                
                for doc in documents {
                    let data = doc.data()
                    let geoPoint = data["userLocation"] as? GeoPoint
                    let timeBox = TimeBox(
                        id: doc.documentID,
                        uid: data["uid"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        imageURL: data["imageURL"] as? [String],
                        userLocation: geoPoint,
                        userLocationTitle: data["userLocationTitle"] as? String ?? "",
                        description: data["description"] as? String,
                        tagFriendUid: data["tagFriendUid"] as? [String],
                        createTimeBoxDate: Timestamp(date: (data["createTimeBoxDate"] as? Timestamp)?.dateValue() ?? Date()),
                        openTimeBoxDate: Timestamp(date: (data["openTimeBoxDate"] as? Timestamp)?.dateValue() ?? Date()),
                        isOpened: data["isOpened"] as? Bool ?? false
                    )
                    print("TimeBox created with ID: \(timeBox.id) and userName: \(timeBox.userName)") // 각 TimeBox 객체 생성 시
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
                    print("All time boxes are processed. Total: \(timeBoxes.count)") // 모든 타임박스 데이터 처리 완료 후
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
            let formattedCreateDate = dateFormatter.string(from: (timeBox.createTimeBoxDate?.dateValue())!)
            let weekday = Calendar.current.component(.weekday, from: (timeBox.createTimeBoxDate?.dateValue())!)
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
import FirebaseAuth

struct Preview: PreviewProvider {
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
