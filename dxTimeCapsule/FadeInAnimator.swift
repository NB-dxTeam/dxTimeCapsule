//
//  FadeInAnimator.swift
//  dxTimeCapsule
//  Created by 김우경 on 2/29/24.
//

import Foundation
import UIKit

class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // 애니메이션 지속 시간 설정
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        toViewController.view.alpha = 0 // 초기 투명도 설정
        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toViewController.view.alpha = 1 // 최종 투명도 설정
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
