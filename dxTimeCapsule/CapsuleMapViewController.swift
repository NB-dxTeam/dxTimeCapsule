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
    
    let capsuleMaps = MKMapView() // 지도 뷰
    var locationManager = CLLocationManager()
    var currentDetent: String? = nil
    // 타임박스 정보와 태그된 친구들의 정보를 담을 배열
    var timeBoxAnnotationsData = [TimeBoxAnnotationData]()
    var timeBoxes: [TimeBox] = []
    var selectedTimeBoxAnnotationData: TimeBoxAnnotationData?
    private var selectedButton: UIButton?
    lazy var friendsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: "FriendCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    // 원래 지도의 중심 위치를 저장할 변수
    private var originalCenterCoordinate: CLLocationCoordinate2D?
    private var shouldShowModal = false
    // 버튼을 생성하고 설정하는 클로저
    private lazy var allButton: UIButton = createRoundButton(named: "all", title: "All")
    private lazy var lockedButton: UIButton = createRoundButton(named: "locked", title: "Locked")
    private lazy var openedButton: UIButton = createRoundButton(named: "opened", title: "Opened")
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [allButton, lockedButton, openedButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
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
        if let image = UIImage(named: "list")?.resizedImage(newSize: CGSize(width: 25, height: 25)) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
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
        updateButtonSelection(allButton)
        selectedButton = allButton
        loadCapsuleInfos(button: .all)
        navigationController?.isNavigationBarHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowModal {
            showModalVC()
        }
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
            make.size.equalTo(CGSize(width: 50, height: 50))
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
        let newLatitudeDelta = min(region.span.latitudeDelta * 2, 180.0)
        let newLongitudeDelta = min(region.span.longitudeDelta * 2, 180.0)
        let zoomedRegion = capsuleMaps.regionThatFits(MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)))
        capsuleMaps.setRegion(zoomedRegion, animated: true)
    }
    private func createRoundButton(named name: String, title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white.withAlphaComponent(0.8) // 배경색을 설정합니다.
        button.layer.cornerRadius = 20 // 모서리를 둥글게 합니다.
        button.snp.makeConstraints { make in // SnapKit을 사용하여 제약조건을 설정합니다.
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
        button.addAction(UIAction { [weak self] _ in
            self?.buttonTapped(name: name)
        }, for: .touchUpInside)
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
    
    // 버튼이 눌렸을 때 호출되는 메서드
    private func buttonTapped(name: String) {
        let buttonToSelect: UIButton
        switch name {
        case "all":
            // 'All' 버튼 로직
            loadCapsuleInfos(button: .all)
            buttonToSelect = allButton
        case "locked":
            // 'Locked' 버튼 로직
            loadCapsuleInfos(button: .locked)
            buttonToSelect = lockedButton
        case "opened":
            // 'Opened' 버튼 로직
            loadCapsuleInfos(button: .opened)
            buttonToSelect = openedButton
        default:
            return
        }
        // 버튼의 선택 상태 업데이트
        updateButtonSelection(buttonToSelect)
        // 현재 선택된 버튼을 저장
        selectedButton = buttonToSelect
    }
    private func updateButtonSelection(_ selectedButton: UIButton) {
        // 모든 버튼을 기본 상태로 리셋
        [allButton, lockedButton, openedButton].forEach {
            $0.backgroundColor = .white.withAlphaComponent(0.8)
            $0.setTitleColor(.black, for: .normal)
        }
        
        // 선택된 버튼의 스타일을 변경
        selectedButton.backgroundColor = .systemBlue
        selectedButton.setTitleColor(.white, for: .normal)
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
    
    // Firestore 쿼리 결과를 처리하는 함수
    func dataCapsule(documents: [QueryDocumentSnapshot]) {
        let group = DispatchGroup()
        
        for doc in documents {
            let data = doc.data()
            let geoPoint = data["location"] as? GeoPoint
            var timeBox = TimeBox(
                id: doc.documentID,
                uid: data["uid"] as? String ?? "",
                userName: data["userName"] as? String ?? "",
                imageURL: data["imageURL"] as? [String],
                location: geoPoint,
                addressTitle: data["addressTitle"] as? String ?? "",
                address: data["address"] as? String ?? "",
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
            self.timeBoxes.append(timeBox)
        }
        
        group.notify(queue: .main) {
            print("데이터 전달. Total count: \(self.timeBoxes.count)")
            // 모든 타임박스 데이터 처리 완료 후 UI 업데이트
            self.addAnnotations(from: self.timeBoxes)
        }
    }
    // 데이터 정보 불러오기
    func loadCapsuleInfos(button: CapsuleFilterButtons) {
            let db = Firestore.firestore()
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            var query: Query
            switch button {
            case .all:
                query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
                    .order(by: "openTimeBoxDate", descending: false)
            case .locked:
                query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
                    .whereField("isOpened", isEqualTo: false)
                    .order(by: "openTimeBoxDate", descending: false)
            case .opened:
                query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
                    .whereField("isOpened", isEqualTo: true)
                    .order(by: "openTimeBoxDate", descending: false)
            }

            query.getDocuments { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self?.dataCapsule(documents: documents)
            }
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let timeBoxAnnotation = annotation as? TimeBoxAnnotation else { return nil }
        print("mapView:viewForAnnotation: called")
        
        let identifier = "CustomAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.animatesWhenAdded = true
            annotationView?.glyphImage = UIImage(named: "boximage1")
            annotationView?.glyphTintColor = .white
            annotationView?.markerTintColor = .red
        } else {
            print("Reusing MKMarkerAnnotationView")
        }
        
        // Ensure the annotationView's annotation is set correctly
        annotationView?.annotation = annotation
        
        // Configure the detailCalloutAccessoryView
        if let timeBoxAnnotation = annotation as? TimeBoxAnnotation {
            print("Configuring detailCalloutAccessoryView for timeBoxAnnotation")
            annotationView?.detailCalloutAccessoryView = configureDetailView(for: timeBoxAnnotation)
        } else {
            print("Annotation is not of type TimeBoxAnnotation")
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let annotation = view.annotation as? TimeBoxAnnotation {
            self.selectedTimeBoxAnnotationData = annotation.timeBoxAnnotationData
            print("selectedTimeBoxAnnotationData is now set with \(self.selectedTimeBoxAnnotationData?.friendsInfo.count ?? 0) friend(s)")
            DispatchQueue.main.async {
                self.friendsCollectionView.reloadData()
            }
        }
    }
}

extension CapsuleMapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = selectedTimeBoxAnnotationData?.friendsInfo.count ?? 0
        print("collectionView:numberOfItemsInSection: \(count) items")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCollectionViewCell", for: indexPath) as? FriendCollectionViewCell,
              let friend = selectedTimeBoxAnnotationData?.friendsInfo[indexPath.row] else {
            print("Error: Unable to dequeue FriendCollectionViewCell or no friend data available")
            return UICollectionViewCell()
        }
        cell.configure(with: friend)
        
        return cell
    }
    
    // Implement this method if you need to handle selection of a friend's cell.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle the friend selection here if necessary.
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

enum CapsuleFilterButtons {
    case all, locked, opened
}
// MARK: - Preview
import SwiftUI
import FirebaseFirestoreInternal
import FirebaseAuth


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
