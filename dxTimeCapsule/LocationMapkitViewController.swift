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
    private var longPressMessageLabel: UILabel!
    
    // MARK: - Constants
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        setupLayout()
        configureLocationServices()
        presentBottomSheetModally()
        hideCenterView()
        isCenterViewPresented = false

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func initializeComponents() {
        mapView = MKMapView()
        mapView.delegate = self
        
        centerView = UIView()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        currentLocationButton = UIButton(type: .system)
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
        setupCurrentLocationButton()
        setupTitleLabelAndButtons()
        setupCenterView() // Ensure centerView is configured
        hideCenterView()
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-20)
            make.width.height.equalTo(50)
        }
    }
    
    // MARK: - Action
    
    private func configureLocationServices() {
          locationManager = CLLocationManager()
          locationManager.delegate = self
          
          if CLLocationManager.locationServicesEnabled() {
              switch locationManager.authorizationStatus {
              case .notDetermined:
                  locationManager.requestWhenInUseAuthorization()
              case .authorizedWhenInUse, .authorizedAlways:
                  locationManager.startUpdatingLocation()
              case .denied, .restricted:
                  // Handle denied or restricted access
                  break
              @unknown default:
                  fatalError("Unhandled case")
              }
          } else {
              // Location services are not enabled
              // Handle this scenario as needed
          }
      }
      
    
    @objc private func currentLocationButtonTapped() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    private func setupTitleLabelAndButtons() {
        titleLabel = UILabel()
        createCapsuleButton = UIButton()
        modifyLocationButton = UIButton() // 추가
        
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
        
        createCapsuleButton.setTitle("여기에 타임캡슐 생성하기", for: .normal)
        createCapsuleButton.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 18)
        createCapsuleButton.layer.cornerRadius = 8
        createCapsuleButton.backgroundColor = UIColor(hex: "#D53369")
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
        modifyLocationButton.setTitleColor(UIColor(hex: "#D53369"), for: .normal)
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
            bannerLabel.textAlignment = .center
            bannerLabel.textColor = .white
            bannerLabel.backgroundColor = .systemBlue
            view.addSubview(bannerLabel)
            bannerLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.left.right.equalToSuperview()
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
    
    @objc private func handleCreateCapsuleTap() {
        let createCapsuleVC = MainCreateCapsuleViewController()
                navigationController?.pushViewController(createCapsuleVC, animated: true)
                print("Create capsule tap")
    }
    // 추가
    @objc private func handleModifyLocationTap() {
            toggleCenterView()
            showBannerMessage(message: "원하는 위치를 꾹 눌러주세요!")
            setupLongPressGesture()

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
    
    
    // MARK: - CLLocationManagerDelegate
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let coordinate = location.coordinate
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + 0.15, longitude: coordinate.longitude)
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
        // 사용자가 어노테이션을 탭했을 때 호출될 메서드
        // 여기서 setupTitleLabelAndButtons() 함수를 호출합니다.
        setupTitleLabelAndButtons()
        
        // 필요한 경우, 선택한 어노테이션에 대한 추가 정보를 처리할 수 있습니다.
        // 예: 어노테이션의 위치 정보를 사용하여 센터 뷰의 내용을 업데이트하거나,
        // 특정 데이터와 연결된 어노테이션인지 확인할 수 있습니다.
    }
    
}
func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    // Handle annotation deselection
}



// MARK: - SwiftUI Preview
import SwiftUI

struct MainTabBarViewPreview2 : PreviewProvider {
    static var previews: some View {
        LocationMapkitViewController().toPreview()
    }
}
