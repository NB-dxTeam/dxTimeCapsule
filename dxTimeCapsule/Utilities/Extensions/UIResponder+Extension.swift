//
//  UIResponder+Extension.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 3/26/24.
//

import UIKit

// 응답자 찾기 위한 확장(키보드)
extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    public static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc internal func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}
