import UIKit
import MapKit
import CoreLocation
import SnapKit

class LocationMapkitViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    // MARK: - Properties
    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocationButton: UIButton!

    private var titleLabel: UILabel!
    private var createCapsuleButton: UIButton!
    private var modifyLocationButton: UIButton!
    
    private var centerView: UIView!
    private let centerViewHeight: CGFloat = 200
    
    
    private var isCenterViewPresented: Bool = false
    
    private var bottomSheetController: BottomSheetViewController!
    private var longPressMessageLabel: UILabel!

    
    // MARK: - Constants
    
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        

        initializeComponents()
        setupLayout()
        configureLocationServices()
        setupLongPressGesture()
        setupTitleLabelAndButtons()
        
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 처음 뷰가 나타날 때 centerView를 보이도록 설정합니다.
        toggleCenterView()
        
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        // Present the bottom sheet modally
        presentBottomSheetModally()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createCapsuleButton.setBlurryBeach()
        modifyLocationButton.tintColor = UIColor(hex: "#D53369")
 
    }
    
    private func initializeComponents() {
        mapView = MKMapView()
        mapView.delegate = self
        
        titleLabel = UILabel()
        createCapsuleButton = UIButton()
        modifyLocationButton = UIButton()
        centerView = UIView()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        currentLocationButton = UIButton(type: .system)

    }
    
    private func setupTitleLabelAndButtons() {
        titleLabel.text = "타임캡슐 생성 위치를 확인해주세요"
          titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
          titleLabel.textAlignment = .center
          centerView.addSubview(titleLabel) // contentView에 추가하도록 수정
          
          titleLabel.snp.makeConstraints { make in
              make.centerX.equalToSuperview() // 수평 중앙에 배치
              make.top.equalToSuperview().offset(60) // 좀 더 위로 이동
          }
        
        createCapsuleButton.setTitle("여기에 타임캡슐 생성하기", for: .normal)
        createCapsuleButton.layer.cornerRadius = 8
        createCapsuleButton.backgroundColor = .systemBlue
        createCapsuleButton.addTarget(self, action: #selector(handleCreateCapsuleTap), for: .touchUpInside)
        centerView.addSubview(createCapsuleButton)
        createCapsuleButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        
        modifyLocationButton.setTitle("위치 수정하기", for: .normal)
        modifyLocationButton.setTitleColor(.systemBlue, for: .normal)
        modifyLocationButton.addTarget(self, action: #selector(handleModifyLocationTap), for: .touchUpInside)
        centerView.addSubview(modifyLocationButton)
        modifyLocationButton.snp.makeConstraints { make in
            make.top.equalTo(createCapsuleButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(centerView.safeAreaLayoutGuide.snp.bottom).inset(20) // safeArea의 하단에 위치하도록 변경
        }
    }
    

    
    private func setupCenterView() {
        centerView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        centerView.layer.cornerRadius = 16
        centerView.layer.shadowOpacity = 0.2
        centerView.layer.shadowRadius = 4.0
        centerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        centerView.layer.shadowColor = UIColor.black.cgColor
        centerView.isHidden = true
        // 센터 뷰 애니메이션
        UIView.animate(withDuration: 0.5) {
            self.centerView.alpha = 1.0 // 또는 다른 애니메이션 효과
        }
        
        view.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(centerViewHeight / 4) // 수직 중앙 위치를 설정합니다.
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(centerViewHeight)
        }
    }
    
    
    
    private func toggleCenterView() {
        isCenterViewPresented.toggle()
        centerView.isHidden = !isCenterViewPresented

        if isCenterViewPresented {
            centerView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.centerView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.centerView.alpha = 0
            }) { _ in
                self.centerView.alpha = 1
                self.centerView.isHidden = true
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func presentBottomSheetModally() {
        let bottomSheetController = BottomSheetViewController()
        if let sheetController = bottomSheetController.presentationController as? UISheetPresentationController {
            sheetController.detents = [.small, .medium(), .large()]
            sheetController.prefersEdgeAttachedInCompactHeight = true
            sheetController.largestUndimmedDetentIdentifier = .medium
      
            
            // 바텀 시트가 표시될 때 .Detent에 맞게 조절될 수 있도록 설정합니다.
            sheetController.selectedDetentIdentifier = .small
        }
        present(bottomSheetController, animated: true, completion: nil)
    }

    
    private func setupLongPressMessageLabel() {
        longPressMessageLabel = UILabel()
        longPressMessageLabel.text = "원하는 장소에 탭을 길게 누르세요"
        longPressMessageLabel.textAlignment = .center
        longPressMessageLabel.textColor = .black
        longPressMessageLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        longPressMessageLabel.layer.cornerRadius = 8
        longPressMessageLabel.clipsToBounds = true
        view.addSubview(longPressMessageLabel)
        longPressMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        longPressMessageLabel.isHidden = true // 초기에는 메시지 레이블을 숨깁니다.
    }
    
    
    
    // MARK: - Setup Layout
    private func setupLayout() {
        setupMapView()
        setupCurrentLocationButton()
        setupCenterView()

    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCurrentLocationButton() {
        currentLocationButton.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        currentLocationButton.tintColor = .systemBlue
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        view.addSubview(currentLocationButton)
        currentLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20) // 수정된 부분
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-20) // 수정된 부분
            make.width.height.equalTo(50)
        }
    }
    
    

    
    

    
    

    


// MARK: - Action
    @objc private func handleCreateCapsuleTap() {
        let createCapsuleVC = MainCreateCapsuleViewController()
        navigationController?.pushViewController(createCapsuleVC, animated: true)
    }
    
    @objc private func handleModifyLocationTap() {
        showAlert(title: "위치 수정", message: "지도에서 새로운 위치를 선택해주세요.")
    }

    
    

    
    // MARK: - Location Services
    private func configureLocationServices() {
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // 위치 서비스 권한이 제한되거나 거부되었습니다. 사용자에게 설정을 변경하도록 안내할 수 있습니다.
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            // 새로운 권한 상태를 처리할 수 있도록 준비합니다.
            fatalError("새로운 권한 상태가 추가되었습니다.")
        }
    }
    
    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // centerView 표시 로직 실행
        // 만약 centerView가 이미 표시된 상태라면 이 로직은 centerView를 숨길 것입니다.
        // 요구사항에 따라 centerView를 항상 표시만 하고 싶다면, isCenterViewPresented 상태를 체크하여 조건적으로 toggleCenterView를 호출하세요.
        if !isCenterViewPresented {
            toggleCenterView()
        }
    }
    
    // MARK: - Gesture


    
 
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    
    @objc func currentLocationButtonTapped() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            mapView.removeAnnotations(mapView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            // 길게 누르기 제스처가 시작될 때 메시지 레이블을 표시합니다.
            longPressMessageLabel.isHidden = false
        } else if gesture.state == .ended {
            // 길게 누르기 제스처가 종료될 때 메시지 레이블을 숨깁니다.
            longPressMessageLabel.isHidden = true
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let coordinate = location.coordinate
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + 0.15, longitude: coordinate.longitude) // 좀 더 위로 핀을 이동시킵니다.
            mapView.addAnnotation(annotation)
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    
}



// MARK: - Preview
import SwiftUI

struct MainTabBarViewPreview : PreviewProvider {
    static var previews: some View {
        MainTabBarView().toPreview()
    }
}
