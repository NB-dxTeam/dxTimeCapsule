import UIKit
import MapKit
import CoreLocation
import SnapKit
import FirebaseFirestore

class LocationMapkitViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    // MARK: - Properties
    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocationButton: UIButton!
    
    private var selectedLocation: CLLocationCoordinate2D?

    private var titleLabel: UILabel!
    private var createCapsuleButton: UIButton!
    private var modifyLocationButton: UIButton!
    private var currentLocationBotton = UIButton()


    private var centerView: UIView!
    private let centerViewHeight: CGFloat = 200
    
    private var isCenterViewPresented: Bool = false
    private var longPressMessageLabel: UILabel!

    private var backButton: UIButton!

    // MARK: - Constants
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        setupLayout()
        configureLocationServices()
        
//        presentBottomSheetModally() // 검색 , 즐겨찾기, 최근검색 기록
        hideCenterView()
        isCenterViewPresented = false

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
          swipeDownGesture.direction = .down
          view.addGestureRecognizer(swipeDownGesture)
        
        // 디버깅 포인트 추가
        print("selectedLocation: \(String(describing: selectedLocation))")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createCapsuleButton.setInstagram()

    }
    
    private func initializeComponents() {
        mapView = MKMapView()
        mapView.delegate = self
        
        centerView = UIView()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        currentLocationButton = UIButton(type: .system)
        
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(hex: "#C82D6B")
        backButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) // Optional: Adjust padding
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }


    
    private func setupCenterView() {
        centerView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        centerView.layer.cornerRadius = 16
        centerView.layer.shadowOpacity = 0.2
        centerView.layer.shadowRadius = 4.0
        centerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        centerView.layer.shadowColor = UIColor.black.cgColor
        view.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(centerViewHeight / 4)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(centerViewHeight)
        }
    }
    
    private func setupLayout() {
        setupMapView()
        setupTitleLabelAndButtons()
        setupCurrentLocationButton()
        setupCenterView()
        hideCenterView()
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
        make.top.equalTo(view.safeAreaLayoutGuide).offset(10)  // Adjust these values as needed
        make.leading.equalTo(view.safeAreaLayoutGuide).offset(10) // Adjust for padding from the left edge
        make.width.height.equalTo(40)  // Adjust based on your design
        }

    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Action
    
    private func configureLocationServices() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                // Handle denied or restricted access with an alert or guidance to settings
                break
            @unknown default:
                fatalError("Unhandled case")
            }
        } else {
            // Location services are not enabled; guide users to enable it in settings
        }
    }
    
    private func setupCurrentLocationButton() {
        view.addSubview(currentLocationBotton) // currentLocationBotton 추가
        
        currentLocationBotton.setImage(UIImage(named: "locationicon"), for: .normal) // 이미지 설정
        currentLocationBotton.setTitleColor(.black, for: .normal)
        currentLocationBotton.layer.backgroundColor = UIColor.white.withAlphaComponent(0.6).cgColor
        currentLocationBotton.layer.cornerRadius = 10
    
        currentLocationBotton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside) // 연결된 함수 설정
        
        currentLocationBotton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20) // 뷰의 safeArea의 위쪽에서 20pt 떨어진 곳에 배치
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20) // 뷰의 safeArea의 오른쪽에서 20pt 떨어진 곳에 배치
            make.width.height.equalTo(40) // 너비와 높이는 40pt로 설정
        }
    }
    
    private func setupTitleLabelAndButtons() {

        titleLabel = UILabel()
        createCapsuleButton = UIButton()
        modifyLocationButton = UIButton()
        
        titleLabel.text = "타임캡슐 생성 위치를 확인해주세요!"
        titleLabel.font = UIFont.pretendardBold(ofSize: 22)
        titleLabel.textColor = .black.withAlphaComponent(0.85)
        titleLabel.textAlignment = .center
        
        // Add titleLabel and createCapsuleButton to centerView
        centerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(centerView).offset(-60)
        }
        
        createCapsuleButton.setTitle("여기에 생성하기", for: .normal)
        createCapsuleButton.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 18)
        createCapsuleButton.layer.cornerRadius = 8
        createCapsuleButton.addTarget(self, action: #selector(handleCreateCapsuleTap), for: .touchUpInside)
        
        centerView.addSubview(createCapsuleButton)
        createCapsuleButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        modifyLocationButton.setTitle("위치 수정하기", for: .normal)
        modifyLocationButton.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 18)
        modifyLocationButton.setTitleColor(UIColor(hex: "#C82D6B"), for: .normal)
        modifyLocationButton.addTarget(self, action: #selector(handleModifyLocationTap), for: .touchUpInside) // 수정
        centerView.addSubview(modifyLocationButton)
        modifyLocationButton.snp.makeConstraints { make in
            make.top.equalTo(createCapsuleButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func toggleCenterView() {
           if isCenterViewPresented {
               hideCenterView()
           } else {
               showCenterView()
           }
       }
    
    private func hideCenterView() {
        if isCenterViewPresented {
            UIView.animate(withDuration: 0.3, animations: {
                self.centerView.alpha = 0
            }) { _ in
                self.centerView.isHidden = true
            }
            isCenterViewPresented = false
        }
    }
    
    private func showCenterView() {
        if !isCenterViewPresented {
            centerView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.centerView.alpha = 1
            }
            isCenterViewPresented = true
        }
    }
    
    private func showBannerMessage(message: String) {
        let bannerLabel = UILabel()
        bannerLabel.text = message
        bannerLabel.font = UIFont.pretendardSemiBold(ofSize: 20)
        bannerLabel.textAlignment = .center
        bannerLabel.textColor = .black
        bannerLabel.layer.cornerRadius = 8
        bannerLabel.layer.masksToBounds = true
        bannerLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.addSubview(bannerLabel)
        bannerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(130)
            make.width.equalTo(350)
            make.height.equalTo(40)
        }
        UIView.animate(withDuration: 0.5, animations: {
            bannerLabel.alpha = 1.0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.animate(withDuration: 0.5, animations: {
                    bannerLabel.alpha = 0.0
                }) { _ in
                    bannerLabel.removeFromSuperview()
                }
            }
        }
    }

    
    @objc func currentLocationButtonTapped() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    
    @objc private func handleCreateCapsuleTap() {
        guard let selectedCoordinate = selectedLocation else {
            // 선택된 위치가 없을 경우, 사용자에게 메시지 표시
            showBannerMessage(message: "캡슐을 생성할 위치를 선택해주세요!")
            return
        }

        let selectedLocation = selectedCoordinate
        
        let photoUploadVC = PhotoUploadViewController()
        photoUploadVC.selectedLocation = selectedLocation // Assuming there's a property in PhotoUploadViewController to hold this
        photoUploadVC.modalPresentationStyle = .overFullScreen // 혹은 .overFullScreen로 설정
        present(photoUploadVC, animated: true, completion: nil)
    }


    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleModifyLocationTap() {
        if isCenterViewPresented {
            hideCenterView()
        } else {
            showBannerMessage(message: "원하는 위치에 탭을 꾹 눌러주세요!")
            setupLongPressGesture()
            showCenterView()
        }
    }
    
    @objc private func closeButtonTapped() {
         dismiss(animated: true, completion: nil)
     }

    
    // MARK: - Gesture
    private func setupLongPressGesture() {
        mapView.gestureRecognizers?.forEach {
            if $0 is UILongPressGestureRecognizer {
                mapView.removeGestureRecognizer($0)
            }
        }
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        print("롱 프레스 감지됨")
        
        if gesture.state == .began {
            print("어노테이션 추가 시작")
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            selectedLocation = coordinate
            
            mapView.removeAnnotations(mapView.annotations)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)

            showCenterView()
            print("어노테이션 추가 완료")
            
            // 위치가 선택되었음을 알리는 메시지를 출력합니다.
            print("Selected Location: \(coordinate)")
        }
    }
    
    @objc private func handleSwipeDown(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // 위치 업데이트 시 사용자의 현재 위치 정보를 처리합니다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 위치 정보 배열에서 최근 위치를 가져옵니다.
        guard let location = locations.last else { return }
        
        // 사용자의 현재 위치를 selectedLocation에 할당합니다.
        selectedLocation = location.coordinate

        // 맵 뷰를 사용자의 현재 위치로 이동합니다.
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)

        // 사용자의 현재 위치에 핀을 추가합니다. (선택적)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)

        // 더 이상 위치 업데이트가 필요하지 않으면 위치 업데이트를 중지합니다.
        manager.stopUpdatingLocation()

        // 사용자의 현재 위치가 업데이트되었으므로 UI를 업데이트합니다.
        updateUIWithCurrentLocation()
    }

    // 위치 권한 변경 시 UI를 업데이트합니다.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            // 위치 권한이 허용되었을 때의 처리
            DispatchQueue.main.async {
                // UI 업데이트 코드 작성
                self.updateUIWithCurrentLocation()
            }
        }
    }


    // 사용자의 현재 위치를 기반으로 UI를 업데이트합니다.
    private func updateUIWithCurrentLocation() {
        // 선택된 위치가 있으면 해당 위치를 사용하여 UI를 업데이트합니다.
        if let selectedLocation = selectedLocation {
            // 이곳에서 UI를 업데이트하는 코드를 작성합니다.
            print("Selected Location: \(selectedLocation)")
        } else {
            // 선택된 위치가 없는 경우 사용자에게 메시지를 표시할 수 있습니다.
            print("No selected location.")
        }
    }

    
    // MARK: - MKMapViewDelegate
    
    // MARK: - CLLocationManagerDelegate
    
    // MKMapViewDelegate 프로토콜을 구현하는 부분에 다음 메서드를 추가하세요.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        setupTitleLabelAndButtons()
    
    }
}
func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    // Handle annotation deselection
}

func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
    // Implement your error handling logic here
    // For example, you could alert the user to check their location settings
}


extension MKMapView {
    func showWorldMap() {
        let coordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            latitudinalMeters: 22000000, // Approximate distance from equator to pole
            longitudinalMeters: 22000000  // Approximate distance from prime meridian to antimeridian
        )
        setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - SwiftUI Preview
//import SwiftUI
//
//struct MainTabBarViewPreview2 : PreviewProvider {
//    static var previews: some View {
//        LocationMapkitViewController().toPreview()
//    }
//}
