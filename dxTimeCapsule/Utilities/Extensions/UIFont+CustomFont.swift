//
//  UIFont+CustomFont.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 2/29/24.
//

import Foundation
import UIKit

extension UIFont {
    static func proximaNovaRegular(ofSize size: CGFloat) -> UIFont? {
        return UIFont(name: "ProximaNova-Regular", size: size)
    }
    
    static func proximaNovaBold(ofSize size: CGFloat) -> UIFont? {
        return UIFont(name: "ProximaNova-Bold", size: size)
    }
    
    static func proximaNovaBlack(ofSize size: CGFloat) -> UIFont? {
        return UIFont(name: "ProximaNova-Black", size: size)
    }
    
    static func pretendardRegular(ofSize size: CGFloat) -> UIFont? {
        return UIFont(name: "Pretendard-Regular", size: size)
    }
    
    static func pretendardSemiBold(ofSize size: CGFloat) -> UIFont? {
        return UIFont(name: "Pretendard-SemiBold", size: size)
    }
}
