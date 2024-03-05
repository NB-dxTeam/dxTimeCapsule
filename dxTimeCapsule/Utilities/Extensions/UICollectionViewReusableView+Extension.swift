//
//  UICollectionViewReusableView+Extension.swift
//  AppleMapUIKit
//
//  Created by Djallil Elkebir on 2023-01-08.
//

import UIKit

extension UICollectionReusableView {
    class var identifier: String {
        return String(describing: self)
    }
    
    class func register(to collectionView: UICollectionView) {
        collectionView.register(self.self, forCellWithReuseIdentifier: identifier)
    }
    
    class func register(forSupplementaryViewOfKind kind: String, to collectionView: UICollectionView) {
        collectionView.register(self.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
}
