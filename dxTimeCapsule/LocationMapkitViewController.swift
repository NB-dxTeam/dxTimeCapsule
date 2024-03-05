import UIKit
import MapKit
import CoreLocation
import Combine
import SnapKit

class LocationMapkitViewController: UIViewController, CLLocationManagerDelegate {
    // MARK: - Properties
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private var viewModel: MainViewModel! // Assuming MainViewModel exists
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var bottomSheetController = BottomSheetViewController(viewModel: .init()) // Assuming BottomSheetViewController exists
    
    private let locationManager = CLLocationManager()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside) // 대상을 self로 변경
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "타임캡슐 생성 위치를 확인해주세요"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let createCapsuleButton: UIButton = {
        let button = UIButton()
        button.setTitle("여기에 타임캡슐 생성하기", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCreateCapsuleTap), for: .touchUpInside)
        return button
    }()

    private let modifyLocationButton: UIButton = {
        let button = UIButton()
        button.setTitle("위치를 수정 하시겠습니까?", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleModifyLocationTap), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        locationManager.delegate = self // Set CLLocationManagerDelegate
        requestLocationAccess()
        addLongPressGesture()
        
        // 바텀시트 표시 로직 추가
        presentBottomSheetController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTapGestureToBackground()
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        setupMapView()
        setupCurrentLocationButton()
        setupTitleLabelAndButtons()
    }

    private func setupTitleLabelAndButtons() {
        view.addSubview(titleLabel)
        view.addSubview(createCapsuleButton)
        view.addSubview(modifyLocationButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        createCapsuleButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }

        modifyLocationButton.snp.makeConstraints { make in
            make.top.equalTo(createCapsuleButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
    }
    
    

    
    // MARK: - Layout
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func presentBottomSheetController() {
        let bottomSheetVC = BottomSheetViewController(viewModel: .init())
        bottomSheetVC.modalPresentationStyle = .automatic
        
        // 현재 활성화된 뷰 컨트롤러를 찾습니다.
        let activeViewController = findActiveViewController()

        // 바텀시트를 현재 활성화된 뷰 컨트롤러에 표시합니다.
        activeViewController?.present(bottomSheetVC, animated: true, completion: nil)
    }

    private func findActiveViewController() -> UIViewController? {
        if let tabBarController = self.tabBarController {
            return tabBarController.selectedViewController
        } else if let navigationController = self.navigationController {
            return navigationController.visibleViewController
        } else {
            return self
        }
    }

    private func setupCurrentLocationButton() {
        view.addSubview(currentLocationButton)
            currentLocationButton.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-200)
                make.width.height.equalTo(48)
            
        }
    }

    
    // MARK: - Actions
    
    @objc private func didTapLocationButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        bottomSheetController.dismiss(animated: true)
    }
    
    @objc private func currentLocationButtonTapped() {
        locationManager.startUpdatingLocation()
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let locationInView = gesture.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    @objc private func handleLocationButtonTap() {
        // Handle the button tap action here
        let alert = UIAlertController(title: "이 위치로 설정하시겠습니까?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // Perform action when user confirms the location
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func handleCreateCapsuleTap() {
        // 타임캡슐 생성 로직 구현
        let alert = UIAlertController(title: "타임캡슐 생성", message: "이 위치에 타임캡슐을 생성하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // 타임캡슐 생성 확인
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc private func handleModifyLocationTap() {
        // 위치 수정 로직 구현
        // 예: 지도에서 다른 위치를 선택하도록 안내
    }

    
    // MARK: - Location Services
    
    private func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus() // iOS 14 이전 버전을 위한 처리
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization() // 앱 사용 중 권한 요청
        }
        getCurrentLocation()
    }
    
    private func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    // 사용자의 현재 위치를 지도에 표시
      private func getCurrentLocation() {
          mapView.showsUserLocation = true // 사용자 위치 표시 활성화
          locationManager.startUpdatingLocation() // 위치 업데이트 시작
      }
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func setupDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.height.equalTo(32)
        }
    }

    @objc private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    
    private func addSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissModal))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }

    @objc private func dismissModal() {
        dismiss(animated: true, completion: nil)
    }



    private func addTapGestureToBackground() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModalByTap))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissModalByTap() {
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.$region
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                self?.mapView.setRegion(region, animated: true)
            }.store(in: &subscriptions)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
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
