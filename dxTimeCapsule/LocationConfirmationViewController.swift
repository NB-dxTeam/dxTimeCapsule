import UIKit
import MapKit
import CoreLocation

class LocationConfirmationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "여기서 타임캡슐을 생성하시나요?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createCapsuleButton: UIButton = {
        let button = UIButton()
        button.setTitle("타임캡슐 생성하기", for: .normal)
        button.backgroundColor = UIColor(hex: "#D53369")
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(LocationConfirmationViewController.self, action: #selector(createCapsuleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("타임캡슐 마저 만들러 가기", for: .normal)
        button.setTitleColor(UIColor(hex: "#D53369"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(LocationConfirmationViewController.self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = .white
         locationManager.delegate = self // CLLocationManagerDelegate 설정
         requestLocationAccess()
         setupMapView()
         setupTitleLabel()
         setupButtons()
    }
    
    // MARK: - Setup UI
    
    private func setupMapView() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 300) // Adjust height as needed
        ])
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupButtons() {
        view.addSubview(createCapsuleButton)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            createCapsuleButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            createCapsuleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCapsuleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCapsuleButton.heightAnchor.constraint(equalToConstant: 50), // Adjust height as needed
            
            continueButton.topAnchor.constraint(equalTo: createCapsuleButton.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50) // Adjust height as needed
        ])
    }
    
    // 위치 서비스 권한 요청
     private func requestLocationAccess() {
         let status = CLLocationManager.authorizationStatus() // iOS 14 이전 버전을 위한 처리
         if status == .notDetermined {
             locationManager.requestWhenInUseAuthorization() // 앱 사용 중 권한 요청
         }
         getCurrentLocation()
     }
    
    // 사용자의 현재 위치를 지도에 표시
      private func getCurrentLocation() {
          mapView.showsUserLocation = true // 사용자 위치 표시 활성화
          locationManager.startUpdatingLocation() // 위치 업데이트 시작
      }
    
    // MARK: - Actions
    
    @objc private func createCapsuleButtonTapped() {
        // Implement action when "타임캡슐 생성하기" button is tapped
    }
    
    @objc private func continueButtonTapped() {
        // Implement action when "타임캡슐 마저 만들러 가기" button is tapped
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            getCurrentLocation() // 권한이 허용되면 위치 가져오기
        } else {
            // 권한 거부 처리...
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}
