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
                guard customCalloutView == nil, let capsuleAnnotation = annotation as? CapsuleAnnotationModel else { return }
                
                let calloutView = CustomCalloutView()
                // CapsuleAnnotationModel에서 TimeBox 정보와 친구 정보를 가져와 CustomCalloutView를 구성합니다.
                calloutView.configure(with: capsuleAnnotation.info, friends: capsuleAnnotation.friends)
                
                self.addSubview(calloutView)
                self.customCalloutView = calloutView
                
            } else {
                // 어노테이션이 선택 해제되었을 때, 콜아웃 뷰를 제거합니다.
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
