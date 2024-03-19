import UIKit
import MapKit
import CoreLocation
import SnapKit

class LocationMapkitViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Properties
    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocationButton: UIButton!
    
    private var centerView: UIView!
    private let centerViewHeight: CGFloat = 200
    private var isCenterViewPresented: Bool = true
    private var closeButton: UIButton!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        setupLayout()
        configureLocationServices()
    }
    
    private func initializeComponents() {
        mapView = MKMapView()
        mapView.delegate = self
        
        centerView = UIView()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        closeButton = UIButton(type: .system)
        closeButton.setTitle("뒤로", for: .normal)
        closeButton.tintColor = UIColor(hex: "#C82D6B") // 확장 UIColor 사용
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        currentLocationButton = UIButton(type: .system)
        currentLocationButton.setImage(UIImage(named: "locationicon"), for: .normal)
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(centerView)
        centerView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        centerView.layer.cornerRadius = 16
        centerView.isHidden = true // Initially hidden
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(40)
        }
        
        view.addSubview(currentLocationButton)
        currentLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(40)
        }
    }
    
    // MARK: - CLLocationManagerDelegate and MKMapViewDelegate methods
    // Please implement required delegate methods for CLLocationManager and MKMapView
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func currentLocationButtonTapped() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func configureLocationServices() {
        locationManager.delegate = self
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() {
            // iOS 14 이상에서는 locationManager 인스턴스의 authorizationStatus 프로퍼티를 사용
            let status = locationManager.authorizationStatus
            
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                // 권한이 거부되었거나 제한된 경우, 사용자에게 안내 메시지 표시 또는 설정으로 유도
                break
            @unknown default:
                fatalError("Unhandled authorization status")
            }
        } else {
            // 위치 서비스가 비활성화된 경우, 사용자에게 설정에서 활성화하도록 안내
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // iOS 14 이상에서 권한 상태 체크
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            // 권한이 아직 결정되지 않은 경우, 권한 요청
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // 권한이 있을 경우, 위치 업데이트 시작
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // 권한이 거부되었거나 제한된 경우, 사용자에게 안내 메시지 표시 또는 설정으로 유도
            break
        @unknown default:
            fatalError("Unhandled authorization status")
        }
    }

    
    @objc private func handleModifyLocationTap() {
        isCenterViewPresented.toggle()
        centerView.isHidden = !isCenterViewPresented
    }
    
    // MARK: Additional methods and logic for centerView, long press gesture, etc.
}
