//
//  etc.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 2/29/24.
//

import Foundation

// 모달 당기는 제스쳐
//@objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//    let translation = gesture.translation(in: view)
//    let velocity = gesture.velocity(in: view)
//    
//    switch gesture.state {
//    case .changed:
//        // 드래그에 따른 뷰의 위치 변경 로직
//        if translation.y > 0 { // 위로 드래그하지 않도록
//            view.transform = CGAffineTransform(translationX: 0, y: translation.y)
//        }
//    case .ended:
//        if translation.y > 100 || velocity.y > 1000 {
//            // 드래그 거리 또는 속도가 임계값을 초과하면 모달 닫기
//            dismiss(animated: true, completion: nil)
//        } else {
//            // 애니메이션으로 원래 위치로 복귀
//            UIView.animate(withDuration: 0.3) {
//                self.view.transform = .identity
//            }
//        }
//    default:
//        break
//    }
//}



//// MARK: - HalfSizePresentationController
//class HalfSizePresentationController: UIPresentationController {
//    override var frameOfPresentedViewInContainerView: CGRect {
//        guard let containerView = containerView else { return CGRect.zero }
//        let originY = containerView.bounds.height / 3 // 화면의 1/3 위치에서 모달이 시작되도록 설정 // 시작 위치
//        return CGRect(x: 0, y: originY, width: containerView.bounds.width, height: containerView.bounds.height * 2 / 3) // 화면의 2/3 만큼의 높이로 모달 크기 설정 /// 사이즈
//    }
//    
//    override func containerViewWillLayoutSubviews() {
//        presentedView?.frame = frameOfPresentedViewInContainerView
//    }
//}
