//
//  CustomPageControl.swift
//  dxTimeCapsule
//
//  Created by 김우경 on 3/22/24.
//

import Foundation
import UIKit

class CustomPageControl: UIPageControl {

    var enlargedIndex: Int = -1 {
        didSet {
            self.updateDots()
        }
    }

    private func updateDots() {
        for (index, subview) in self.subviews.enumerated() {
            if index == self.numberOfPages - 1 && index != self.currentPage {
                // 마지막 인디케이터, 그리고 현재 페이지가 아닐 때만 크게 설정
                subview.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            } else {
                // 그 외는 원래 크기로 설정
                subview.transform = CGAffineTransform.identity
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateDots()
    }
}
