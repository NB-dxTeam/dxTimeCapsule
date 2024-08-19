import UIKit
import MapKit
import CoreLocation
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class CapsuleMapViewController: UIViewController {
    
    // MARK: - Properties
    let capsuleMapView = CapsuleMapView() // 지도 뷰
    private var locationService = LocationService()
    private var firestroeService = FirestoreDataService()
    var timeBoxAnnotationsData = [TimeBoxAnnotationData]()
    var selectedTimeBoxAnnotationData: TimeBoxAnnotationData?
    var timeBoxes: [TimeBox] = []
    var currentDetent: String? = nil
    var selectedButton: UIButton?
    // 원래 지도의 중심 위치를 저장할 변수
    private var originalCenterCoordinate: CLLocationCoordinate2D?
    private var shouldShowModal = false
    
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
    
    
    // 컨트롤러의 view 계층 구조 생성
    override func loadView() {
        view = capsuleMapView
    }
    
    // view 계층 구조가 메모리에 로드되었으며, 초기화 작업을 수행
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        configureButtons()
        locationService.setupLocationManager()
        setupMapView()
        updateButtonSelection(capsuleMapView.allButton)
        selectedButton = capsuleMapView.allButton
    }
    
    // view가 화면에 나타나기 직전에 호출. ex) 애니메이션 시작, view를 업데이트
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // view가 화면에 나타나면 호출. ex) 애니메이션 종료, view 상태를 업데이트
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowModal {
            showModalVC()
        }
    }
    
    // view가 화면에서 사라지기 직전에 호출. ex) 데이터 저장, 애니메이션 시작
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // view가 화면에서 사라지면 호출. ex) 애니메이션 종료, view의 상태를 업데이트
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // 객체 메모리 해제
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("NotificationCenter removeObserver")
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.hidesBackButton = true
        
        let backButton = createNavButton(imageName: "chevron.left", isSystemImage: true, action: #selector(backButtonTapped))
        backButton.tintColor = UIColor(red: 209/255.0, green: 94/255.0, blue: 107/255.0, alpha: 1)
        
        let currentLocationButton = createNavButton(imageName: "locationicon", isSystemImage: false, action: #selector(locationButton))
        currentLocationButton.tintColor = .black
        currentLocationButton.backgroundColor = .white
        
        let buttonsStackView = UIStackView(arrangedSubviews: [capsuleMapView.allButton, capsuleMapView.lockedButton, capsuleMapView.openedButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.alignment = .center
        buttonsStackView.spacing = 20
        
        navigationController?.navigationBar.addSubview(backButton)
        navigationController?.navigationBar.addSubview(currentLocationButton)
        navigationController?.navigationBar.addSubview(buttonsStackView)
        
        backButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalTo(navigationController!.navigationBar)
            make.leading.equalTo(navigationController!.navigationBar).offset(20)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalTo(navigationController!.navigationBar)
            make.trailing.equalTo(navigationController!.navigationBar).offset(-20)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(20)
            make.trailing.equalTo(currentLocationButton.snp.leading).offset(-20)
            make.centerY.equalTo(navigationController!.navigationBar)
        }
    }
    
    private func createNavButton(imageName: String, isSystemImage: Bool, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let image: UIImage?
        
        if isSystemImage {
            image = UIImage(systemName: imageName)?.resizedImage(newSize: CGSize(width: 20, height: 20))
        } else {
            image = UIImage(named: imageName)?.resizedImage(newSize: CGSize(width: 20, height: 20))
        }
        
        if let image = image {
            button.setImage(image, for: .normal)
        }
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func configureButtons() {
        setupButtonActions()
        setupFilterButtonActions()
    }
    
    private func setupButtonActions() {
        capsuleMapView.tapDidModalButton.addTarget(self, action: #selector(modalButton), for: .touchUpInside)
        capsuleMapView.zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        capsuleMapView.zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
    }
    
    private func setupFilterButtonActions() {
        let buttonActions: [(UIButton, String)] = [
            (capsuleMapView.allButton, "all"),
            (capsuleMapView.lockedButton, "locked"),
            (capsuleMapView.openedButton, "opened")
        ]
        
        for (button, name) in buttonActions {
            button.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }
                self.buttonTapped(name: name)
            }, for: .touchUpInside)
        }
    }
    
    
    
    // 버튼이 눌렸을 때 호출되는 메서드
    private func buttonTapped(name: String) {
        capsuleMapView.mapView.removeAnnotations(capsuleMapView.mapView.annotations)
        
        let action: BoxFilterAction
        switch name {
        case "all":
            // 'All' 버튼 로직
            action = AllFilterAction(viewController: self)
        case "locked":
            // 'Locked' 버튼 로직
            action = LockedFilterAction(viewController: self)
        case "opened":
            // 'Opened' 버튼 로직
            action = OpenedFilterAction(viewController: self)
        default:
            return
        }
        action.performAction()
        NotificationCenter.default.post(name: .capsuleButtonTapped, object: nil, userInfo: ["status": name])
    }
    
    func updateButtonSelection(_ selectedButton: UIButton) {
        // 모든 버튼을 기본 상태로 리셋
        [capsuleMapView.allButton, capsuleMapView.lockedButton, capsuleMapView.openedButton].forEach {
            $0.backgroundColor = .white.withAlphaComponent(0.75)
            $0.setTitleColor(UIColor(hex: "#d65451"), for: .normal) // 필터 색상
        }
        
        // 선택된 필터 버튼의 스타일을 변경
        selectedButton.backgroundColor = UIColor(hex: "#d65451") // 필터 선택 시 배경 색상
        selectedButton.setTitleColor(.white, for: .normal)
        
        self.selectedButton = selectedButton
    }
    
}

extension CapsuleMapViewController {
    // MARK: - Action
    
    @objc private func zoomIn() {
        let region = MKCoordinateRegion(center: capsuleMapView.mapView.centerCoordinate, span: capsuleMapView.mapView.region.span)
        let zoomRegion = capsuleMapView.mapView.regionThatFits(MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2, longitudeDelta: region.span.longitudeDelta / 2)))
        capsuleMapView.mapView.setRegion(zoomRegion, animated: true)
    }
    
    @objc private func zoomOut() {
        let region = MKCoordinateRegion(center: capsuleMapView.mapView.centerCoordinate, span: capsuleMapView.mapView.region.span)
        let newLatitudeDelta = min(region.span.latitudeDelta * 2, 180.0)
        let newLongitudeDelta = min(region.span.longitudeDelta * 2, 180.0)
        let zoomedRegion = capsuleMapView.mapView.regionThatFits(MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)))
        capsuleMapView.mapView.setRegion(zoomedRegion, animated: true)
    }
    
    @objc func modalButton(_ sender: UIButton) {
        showModalVC()
    }
    // 지도 현재 위치로 이동
    @objc func locationButton(_ sender: UIButton) {
        capsuleMapView.mapView.setUserTrackingMode(.follow, animated: true)
           // 적절한 줌 레벨로 조정하기 위해 추가
        let region = MKCoordinateRegion(center: capsuleMapView.mapView.userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        capsuleMapView.mapView.setRegion(region, animated: true)
    }
    
    @objc private func backButtonTapped() {
        if let presentedVC = presentedViewController, presentedVC is TimeBoxListViewController {
            presentedVC.dismiss(animated: true) { [weak self] in
                self?.tabBarController?.selectedIndex = 0
            }
        } else {
            self.tabBarController?.selectedIndex = 0
        }
    }
}

extension CapsuleMapViewController {
    
    // Firestore 쿼리 결과를 처리하는 함수
    private func dataCapsule(documents: [QueryDocumentSnapshot]) {
        let group = DispatchGroup()
        var tempTimeBoxes = [TimeBox]()
        var tempAnnotationsData = [TimeBoxAnnotationData]()
        
        for doc in documents {
            let data = doc.data()
            let timeBox = TimeBoxCreated.createTimeBox(from: data, documentID: doc.documentID)
            tempTimeBoxes.append(timeBox)
                    
            group.enter()
            
            if let tagFriendUids = timeBox.tagFriendUid, !tagFriendUids.isEmpty {
                FirestoreDataService().fetchFriendsInfo(byUIDs: tagFriendUids) { [weak self] friendsInfo in
                    defer { group.leave() }
                    guard let self = self, let friendsInfo = friendsInfo, !friendsInfo.isEmpty else { return }
                    
                    let annotationData = TimeBoxAnnotationData(timeBox: timeBox, friendsInfo: friendsInfo)
                    tempAnnotationsData.append(annotationData)
                }
            } else {
                
                let annotationData = TimeBoxAnnotationData(timeBox: timeBox, friendsInfo: [])
                tempAnnotationsData.append(annotationData)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.timeBoxes = tempTimeBoxes
            self.addAnnotations(with: tempAnnotationsData)
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
            query = db.collection("timeCapsules")
                .whereField("uid", isEqualTo: userId)
                .whereField("isOpened", isEqualTo: false)
        case .opened:
            query = db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
                .whereField("isOpened", isEqualTo: true)
        }
        
        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            print("눌린 버튼: \(button)")
            self?.dataCapsule(documents: documents)
        }
    }
}
extension CapsuleMapViewController {
    func showModalVC() {
        let vc = TimeBoxListViewController()
        vc.isModalInPresentation = false
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
                        sheet.prefersGrabberVisible = true
                        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                        sheet.prefersEdgeAttachedInCompactHeight = true
                        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    }
                }
            }
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.half, .large()]
            sheet.selectedDetentIdentifier = .half
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            
        }
        //vc.isModalInPresentation = true
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true)
    }

    func moveToLocation(latitude: Double, longitude: Double) {
        let adjustedLatitude = latitude
        let adjustedLongitude = longitude
        let location = CLLocationCoordinate2D(latitude: adjustedLatitude, longitude: adjustedLongitude)
        // 셀 탭했을 때, 줌 상태
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
        capsuleMapView.mapView.setRegion(region, animated: true)
    }
    // 하프 모달 버튼 동작
    
}

// MARK: -MKMapViewDalegate
extension CapsuleMapViewController: MKMapViewDelegate {
    func setupMapView() {
        // 대리자를 뷰컨으로 설정
        capsuleMapView.mapView.delegate = self
        capsuleMapView.mapView.showsCompass = false
        
        // 위치 사용 시 사용자의 현재 위치 표시
        capsuleMapView.mapView.showsUserLocation = true
        capsuleMapView.mapView.layer.masksToBounds = true
        capsuleMapView.mapView.layer.cornerRadius = 0
        
        // 애니메이션 효과가 추가 되어 부드럽게 화면 확대 및 이동
        capsuleMapView.mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        let initalLocation = CLLocation(latitude: 35.9333, longitude: 127.9933)
        let regionRadius: CLLocationDistance = 400000
        let coordinateRegion = MKCoordinateRegion(center: initalLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        capsuleMapView.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let timeBoxAnnotation = annotation as? TimeBoxAnnotation else { return nil }
        let identifier = "CustomAnnotationView"
           
           var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
           
           if annotationView == nil {
               print("새 MKMarkerAnnotationView 생성")
               annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
               configureAnnotationView(annotationView, with: timeBoxAnnotation)
           } else {
               print("MKMarkerAnnotationView 재사용")
               configureAnnotationView(annotationView, with: timeBoxAnnotation)
           }
           
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? TimeBoxAnnotation {
            self.selectedTimeBoxAnnotationData = annotation.timeBoxAnnotationData
            print("selectedTimeBoxAnnotationData is now set with \(self.selectedTimeBoxAnnotationData?.friendsInfo.count ?? 0) friend(s)")
            DispatchQueue.main.async {
                self.friendsCollectionView.reloadData()
                print("어노테이션이 선택됨: \(annotation)")
            }
        }
        
    }
    
    func configureAnnotationView(_ annotationView: MKMarkerAnnotationView?, with timeBoxAnnotation: TimeBoxAnnotation) {
        guard let annotationView = annotationView else { return }
        
        annotationView.canShowCallout = true
        annotationView.animatesWhenAdded = true
        annotationView.glyphImage = UIImage(named: "boximage1")
        annotationView.glyphTintColor = .white
        annotationView.markerTintColor = timeBoxAnnotation.timeBoxAnnotationData?.timeBox.isOpened ?? false ? .systemGray4 : .systemRed
        annotationView.clusteringIdentifier = "timeBoxCluster"
        annotationView.detailCalloutAccessoryView = configureDetailView(for: timeBoxAnnotation)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension Notification.Name {
    static let capsuleButtonTapped = Notification.Name("capsuleButtonTapped")
}
enum CapsuleFilterButtons {
    case all, locked, opened
}

// MARK: - Preview
import SwiftUI

//struct PreView: PreviewProvider {
//    static var previews: some View {
//        CapsuleMapViewController().toPreview()
//    }
//}
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

