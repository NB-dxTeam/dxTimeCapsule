//
//  CapsuleMapViewController.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit

class CapsuleMapViewController: UIViewController, CLLocationManagerDelegate {
    
    private let capsuleMaps = MKMapView()
    var locationManager = CLLocationManager()
    private var tapDidModal: UIButton = {
        let button = UIButton()
        button.setTitle("타임캡슐보기", for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        autoLayouts()
        locationSetting()
        showModalVC()
        setupMapView()
        tapDidModal.addTarget(self, action: #selector(modalButton(_:)), for: .touchUpInside)
    }
    
}

extension CapsuleMapViewController {
    private func addSubViews() {
        self.view.addSubview(capsuleMaps)
        self.view.addSubview(tapDidModal)
    }
    
    private func autoLayouts() {
        capsuleMaps.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tapDidModal.snp.top)
        }
        tapDidModal.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CapsuleMapViewController {
    func locationSetting() {
        locationManager.delegate = self
        // 배터리에 맞게 권장되는 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 사용자 위치 권한 요청
        locationManager.requestWhenInUseAuthorization()
        // 위치 업데이트
        locationManager.startUpdatingLocation()
    }
    
    
}
extension CapsuleMapViewController {
    func showModalVC() {
        let vc = CustomModal()
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        self.present(vc, animated: true)
    }
    
    
    @objc func modalButton(_ sender: UIButton) {
        showModalVC()
        
    }
}

// MARK: -MKMapViewDalegate
extension CapsuleMapViewController: MKMapViewDelegate {
    func setupMapView() {
        // 대리자를 뷰컨으로 설정
        capsuleMaps.delegate = self
        
        // 위치 사용 시 사용자의 현재 위치 표시
        capsuleMaps.showsUserLocation = true
        
        // 사용자 위치 추적
        // 현재 위치를 보여줌
        capsuleMaps.userTrackingMode = .follow
        // 핸드폰 방향에 따라 지도를 회전(앞에 레이더 포함)
        //capsuleMaps.userTrackingMode = .followWithHeading
        
        // 애니메이션 효과가 추가 되어 부드럽게 화면 확대 및 이동
        //capsuleMaps.setUserTrackingMode(.follow, animated: true)
        //capsuleMaps.setUserTrackingMode(.followWithHeading, animated: true)
    }
    
    // 지도를 스크롤 및 확대할 때, 호출 됨. 즉, 지도 영역이 변경될 때 호출
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("지도 위치 변경")
    }
    
    // 사용자 위치가 업데이트 될 때, 호출 ( 캡슐 셀 텝 동작시 해당지역 확대 로직 여기에 추가)
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        capsuleMaps.setRegion(region, animated: true)
    }
    
    
}
// MARK: - Preview
import SwiftUI

struct PreView: PreviewProvider {
    static var previews: some View {
        CapsuleMapViewController().toPreview()
    }
}

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

