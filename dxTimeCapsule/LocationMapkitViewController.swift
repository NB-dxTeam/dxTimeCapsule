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
    private var currentLocationBotton = UIButton()


    private var centerView: UIView!
    private let centerViewHeight: CGFloat = 200
    
    private var isCenterViewPresented: Bool = false
    private var longPressMessageLabel: UILabel!

    private var closeButton: UIButton!

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
        
        closeButton = UIButton(type: .system)
        closeButton.setTitle("뒤로", for: .normal)
        closeButton.tintColor = UIColor(hex: "#C82D6B")
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
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
        
        // 닫기 버튼 레이아웃 설정
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(40)
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
        mapView.showsUserLocation = true // Make sure the map view shows the user location
        
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
        // Ensure this line is reached during execution by adding a print statement or breakpoint here.
        
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

    private func presentBottomSheetModally() {
        let bottomSheetController = BottomSheetViewController() // Assign to class property
        if let sheetController = bottomSheetController.presentationController as? UISheetPresentationController {
            sheetController.detents = [.small, .medium(), .large()]
            sheetController.prefersEdgeAttachedInCompactHeight = true
            sheetController.largestUndimmedDetentIdentifier = .medium
            sheetController.selectedDetentIdentifier = .small
        }
        present(bottomSheetController, animated: true, completion: nil)
    }
    
    @objc func currentLocationButtonTapped() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    
    @objc private func handleCreateCapsuleTap() {
        let photoUploadVC = PhotoUploadViewController()
        photoUploadVC.modalPresentationStyle = .fullScreen // 또는 .overFullScreen
        present(photoUploadVC, animated: true, completion: nil)
    }

    @objc private func handleModifyLocationTap() {
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
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            mapView.removeAnnotations(mapView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            showCenterView()
        }
    }
    
    @objc private func handleSwipeDown(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            var coordinate = location.coordinate
            // Adjusting latitude by adding 0.015 to slightly shift the map view up
            coordinate.latitude -= 0.015

            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)

            // Optionally, you might want to add an annotation at the user's actual location
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate // Use the original coordinate here
            mapView.addAnnotation(annotation)
        }
    }

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle authorization status changes
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

