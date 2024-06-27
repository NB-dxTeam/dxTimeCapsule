//
//  CapsuleMapVC+Extensions.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/19/24.
//

import UIKit
import MapKit
import SnapKit


extension CapsuleMapViewController {
    
    func configureDetailView(for annotation: TimeBoxAnnotation) -> UIView {
        self.selectedTimeBoxAnnotationData = annotation.timeBoxAnnotationData
        // 상세 뷰의 기본 구성
        let detailView = UIView()
        detailView.layer.cornerRadius = 8
        detailView.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        detailView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        // 타이틀, 생성일, 개봉일 레이블 및 친구 목록 추가
        if let timeBoxData = self.selectedTimeBoxAnnotationData {
            addLabel(to: stackView, with: timeBoxData.timeBox.addressTitle ?? "Unknown Location", fontSize: 18, isBold: true)
            addDateView(to: stackView, title: "생성일", date: timeBoxData.timeBox.createTimeBoxDate?.dateValue(), using: dateFormatter)
            addDateView(to: stackView, title: "개봉일", date: timeBoxData.timeBox.openTimeBoxDate?.dateValue(), using: dateFormatter)
            
            // 친구 목록이 있다면, 친구 목록 추가
            if !timeBoxData.friendsInfo.isEmpty {
                stackView.addArrangedSubview(friendsCollectionView)
                friendsCollectionView.snp.makeConstraints { make in
                    make.height.equalTo(80)
                    make.leading.trailing.equalToSuperview()
                }
                DispatchQueue.main.async {
                    self.friendsCollectionView.reloadData()
                }
            }
        }
        
        // 로딩 인디케이터 추가
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        detailView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.startAnimating()
        
        // 로딩 인디케이터가 몇 초 후에 사라지도록 설정
        // 이 부분은 실제 데이터 로딩 로직이 완료되면 로딩 인디케이터를 중지하고 숨기는 부분입니다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        
        return detailView
    }
    
    private func addLabel(to stackView: UIStackView, with text: String, fontSize: CGFloat, isBold: Bool) {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.numberOfLines = 0
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        stackView.addArrangedSubview(label)
    }
    
    private func addDateView(to stackView: UIStackView, title: String, date: Date?, using dateFormatter: DateFormatter) {
        guard let date = date else { return }
        let dateView = UIStackView()
        dateView.axis = .horizontal
        dateView.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .gray
        
        let dateLabel = UILabel()
        dateLabel.text = dateFormatter.string(from: date)
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        
        dateView.addArrangedSubview(titleLabel)
        dateView.addArrangedSubview(dateLabel)
        
        stackView.addArrangedSubview(dateView)
    }
    
    func addAnnotations(with annotationsData: [TimeBoxAnnotationData]) {
        capsuleMapView.mapView.removeAnnotations(capsuleMapView.mapView.annotations) // Remove all current annotations
        
        for annotationData in annotationsData {
            guard let location = annotationData.timeBox.location else { continue }
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let annotation = TimeBoxAnnotation(coordinate: coordinate, timeBoxAnnotationData: annotationData)
            capsuleMapView.mapView.addAnnotation(annotation)
        }
    }

}
