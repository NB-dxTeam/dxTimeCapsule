import UIKit
import MapKit
import CoreLocation
import SnapKit

class LocationMapkitViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocationButton: UIButton!
    private var titleLabel: UILabel!
    private var createCapsuleButton: UIButton!
    private var modifyLocationButton: UIButton!
    private var centerView: UIView!
    private var bottomSheetController: BottomSheetViewController!

    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        setupLayout()
        configureLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           presentBottomSheetController()
       }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        createCapsuleButton.setBlurryBeach()
        createCapsuleButton.tintColor = UIColor(hex: "#D53369")
        createCapsuleButton.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
    }

    private func initializeComponents() {
        mapView = MKMapView()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        currentLocationButton = UIButton(type: .system)
        titleLabel = UILabel()
        createCapsuleButton = UIButton()
        modifyLocationButton = UIButton()
        bottomSheetController = BottomSheetViewController()
        centerView = UIView()
    }

    // MARK: - Setup Layout
    private func setupLayout() {
        setupMapView()
        setupCurrentLocationButton()
        setupTitleLabelAndButtons()
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(50)
        }
    }
    
// MARK: - Setup UI & Layout
    
    private func setupTitleLabelAndButtons() {
        // 타이틀 레이블 설정
        titleLabel.text = "타임캡슐 생성 위치를 확인해주세요"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        centerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.top).offset(20) // centerView의 상단으로부터 20pt 떨어진 위치에 배치
            make.left.equalTo(centerView.snp.left).offset(20)
            make.right.equalTo(centerView.snp.right).inset(20)
        }

        // 타임캡슐 생성 버튼 설정
        createCapsuleButton.setTitle("여기에 타임캡슐 생성하기", for: .normal)
        createCapsuleButton.layer.cornerRadius = 8
        createCapsuleButton.addTarget(self, action: #selector(handleCreateCapsuleTap), for: .touchUpInside)

        centerView.addSubview(createCapsuleButton)
        createCapsuleButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10) // 타이틀 레이블 아래로 10pt 떨어진 위치에 배치
            make.left.equalTo(centerView.snp.left).offset(20)
            make.right.equalTo(centerView.snp.right).inset(20)
            make.height.equalTo(50) // 버튼의 높이를 50pt로 설정
        }
        


        // 위치 수정 버튼 설정
        modifyLocationButton.setTitle("위치를 수정 하시겠습니까?", for: .normal)
        modifyLocationButton.setTitleColor(UIColor.systemBlue, for: .normal)
        modifyLocationButton.addTarget(self, action: #selector(handleModifyLocationTap), for: .touchUpInside)
        centerView.addSubview(modifyLocationButton)
        modifyLocationButton.snp.makeConstraints { make in
            make.top.equalTo(createCapsuleButton.snp.bottom).offset(10) // 생성 버튼 아래로 10pt 떨어진 위치에 배치
            make.left.equalTo(centerView.snp.left).offset(20)
            make.right.equalTo(centerView.snp.right).inset(20)
            make.height.equalTo(50) // 버튼의 높이를 50pt로 설정
            make.bottom.equalTo(centerView.snp.bottom).inset(20) // 이를 통해 centerView의 크기가 자동으로 조절될 수 있도록 설정
        }
    }

    private func setupCenterView() {
        // 배경색에 투명도를 적용하여 설정합니다. 여기서 0.95는 예시 값이며, 필요에 따라 조절 가능합니다.
        centerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        centerView.layer.cornerRadius = 16  // 모서리 둥글게
        centerView.layer.shadowOpacity = 0.2  // 그림자 투명도
        centerView.layer.shadowRadius = 4.0  // 그림자 블러 반경
        centerView.layer.shadowOffset = CGSize(width: 0, height: 2)  // 그림자 위치 조정
        centerView.layer.shadowColor = UIColor.black.cgColor  // 그림자 색상
        
        view.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(200)  // 필요에 따라 높이 조절
        }
    }


   
    private func presentBottomSheetController() {
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .automatic
        present(bottomSheetVC, animated: true, completion: nil)
    }

    // MARK: - Location Services
    private func configureLocationServices() {
        requestLocationAccess()
    }

    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }

    @objc func currentLocationButtonTapped() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    @objc private func handleCreateCapsuleTap() {
        // 타임캡슐 생성 로직 구현
        showAlert(title: "타임캡슐 생성", message: "이 위치에 타임캡슐을 생성하시겠습니까?")
    }

    @objc private func handleModifyLocationTap() {
        // 위치 수정 로직 구현
        showAlert(title: "위치 수정", message: "지도에서 새로운 위치를 선택해주세요.")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
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
