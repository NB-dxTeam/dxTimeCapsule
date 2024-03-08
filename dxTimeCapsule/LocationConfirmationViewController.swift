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
        label.text = "타임캡슐 생성 위치를 확인해주세요"
        label.font = UIFont.pretendardSemiBold(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createCapsuleButton: UIButton = {
        let button = UIButton()
        button.setTitle("여기에 타임캡슐 생성하기", for: .normal)
        button.backgroundColor = UIColor(hex: "#D53369")
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(LocationConfirmationViewController.self, action: #selector(createCapsuleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("위치를 수정 하시겠습니까?", for: .normal)
        button.setTitleColor(UIColor(hex: "#D53369"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(LocationConfirmationViewController.self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 현재 위치로 돌아가는 버튼 추가
      private let currentLocationButton: UIButton = {
          let button = UIButton(type: .system)
          button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
          button.tintColor = .systemBlue
          button.translatesAutoresizingMaskIntoConstraints = false
          button.addTarget(LocationConfirmationViewController.self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
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
    
    private func setupCurrentLocationButton() {
            view.addSubview(currentLocationButton)
            NSLayoutConstraint.activate([
                currentLocationButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
                currentLocationButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
                currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
                currentLocationButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    private func addLongPressGesture() {
         let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
         mapView.addGestureRecognizer(longPressGesture)
     }

    
    // MARK: - Actions
    
    @objc private func continueButtonTapped() {
        // Implement action when "타임캡슐 마저 만들러 가기" button is tapped
        dismiss(animated: true, completion: nil)
    }
    
    @objc func currentLocationButtonTapped() {
        locationManager.startUpdatingLocation()
    }
    
    // action when "타임캡슐 생성하기" button is tapped
    @objc func createCapsuleButtonTapped() {
        if let currentLocation = locationManager.location?.coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = currentLocation
            mapView.addAnnotation(annotation)
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
          if gesture.state == .began {
              let locationInView = gesture.location(in: mapView)
              let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
              let annotation = MKPointAnnotation()
              annotation.coordinate = coordinate
              mapView.addAnnotation(annotation)
          }
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

// MARK: - Preview
import SwiftUI

struct PreView1 : PreviewProvider {
    static var previews: some View {
    LocationConfirmationViewController().toPreview()
    }
}
