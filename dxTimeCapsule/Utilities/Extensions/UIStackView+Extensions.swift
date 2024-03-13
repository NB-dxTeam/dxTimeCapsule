//
//  UIStackView+Extensions.swift
//  AppleMapUIKit
//
//  Created by Djallil Elkebir on 2023-01-08.
//

import UIKit

public extension UIStackView {
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach({
            self.addArrangedSubview($0)
        })
    }
}

public extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach({self.addSubview($0)})
    }
}
