//
//  CapsuleAnnotationView.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/13/24.
//

import UIKit
import MapKit

class CapsuleAnnotationView: MKAnnotationView {
    
    var customCalloutView: CustomCalloutView?
    
    override var annotation: MKAnnotation? {
        willSet {
            customCalloutView?.removeFromSuperview()
        }
    }
    
    // 콜 아웃이 선택되고 취소 될 때 동작
    override var isSelected: Bool {
        didSet {
            if isSelected {
                if customCalloutView == nil, let capsuleAnnotation = annotation as? CapsuleAnnotationModel {
                    // 콜아웃 초기화 및 구성
                    customCalloutView = CustomCalloutView()
                    if let calloutView = customCalloutView {
                        calloutView.configure(with: capsuleAnnotation.info)
                        addSubview(calloutView)
                        // 콜아웃을 배치하고 필요에 따라 크기를 조정
                        calloutView.translatesAutoresizingMaskIntoConstraints = false
                        calloutView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                        calloutView.bottomAnchor.constraint(equalTo: self.topAnchor).isActive = true
                    }
                }
            } else {
                // 주석 선택 해제 시 맞춤 설명선 제거
                customCalloutView?.removeFromSuperview()
                customCalloutView = nil
            }
        }
    }
    
    // 커스텀 뷰의 레이아웃을 정의할 때 사용
    override func layoutSubviews() {
        super.layoutSubviews()
        if let calloutView = customCalloutView {
            bringSubviewToFront(calloutView)
        }
    }
    
    // 어노테이션 보기 탭 동작 처리
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let result = customCalloutView?.hitTest(convert(point, to: customCalloutView), with: event) {
            return result
        }
        return super.hitTest(point, with: event)
    }
}
