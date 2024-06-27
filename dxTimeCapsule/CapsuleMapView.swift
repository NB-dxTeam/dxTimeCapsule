//
//  CapsuleMapView.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 6/24/24.
//

import UIKit
import MapKit
import SnapKit


class CapsuleMapView: UIView {
    let mapView = MKMapView()
    let tapDidModalButton = UIButton()
    let zoomBackgroundView = UIView()
    let zoomInButton = UIButton(type: .system)
    let zoomOutButton = UIButton(type: .system)
    
    let allButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체", for: .normal)
        button.tintColor = UIColor(hex: "#d65451")
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    let lockedButton: UIButton = {
        let button = UIButton()
        button.setTitle("잠김", for: .normal)
        button.tintColor = UIColor(hex: "#d65451")
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    let openedButton: UIButton = {
        let button = UIButton()
        button.setTitle("열림", for: .normal)
        button.tintColor = UIColor(hex: "#d65451")
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupConstraints()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(mapView)
        addSubview(tapDidModalButton)
        addSubview(zoomBackgroundView)
        zoomBackgroundView.addSubview(zoomInButton)
        zoomBackgroundView.addSubview(zoomOutButton)
        addSubview(allButton)
        addSubview(lockedButton)
        addSubview(openedButton)
        
        tapDidModalButton.setImage(UIImage(named: "list")?.resizedImage(newSize: CGSize(width: 25, height: 25)), for: .normal)
        tapDidModalButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        tapDidModalButton.layer.cornerRadius = 25
        
        zoomBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        zoomBackgroundView.layer.cornerRadius = 20
        zoomInButton.setImage(UIImage(systemName: "plus"), for: .normal)
        zoomInButton.tintColor = .white
        zoomOutButton.setImage(UIImage(systemName: "minus"), for: .normal)
        zoomOutButton.tintColor = .white
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        tapDidModalButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(mapView).offset(-20)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        zoomBackgroundView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalTo(40)
            make.height.equalTo(120)
        }
        
        zoomInButton.snp.makeConstraints { make in
            make.top.equalTo(zoomBackgroundView).offset(10)
            make.centerX.equalTo(zoomBackgroundView)
            make.width.equalTo(zoomBackgroundView.snp.width).multipliedBy(0.6)
            make.height.equalTo(zoomInButton.snp.width)
        }
        
        zoomOutButton.snp.makeConstraints { make in
            make.bottom.equalTo(zoomBackgroundView).offset(-10)
            make.centerX.equalTo(zoomBackgroundView)
            make.width.equalTo(zoomBackgroundView.snp.width).multipliedBy(0.6)
            make.height.equalTo(zoomOutButton.snp.width)
        }
        
        allButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(tapDidModalButton.snp.top).offset(-10)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        lockedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tapDidModalButton.snp.top).offset(-10)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        openedButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(tapDidModalButton.snp.top).offset(-10)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
    }
}
