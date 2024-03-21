//
//  UIImage+roundedImage.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 2/29/24.
//

import UIKit

extension UIImage {
    func roundedImage() -> UIImage? {
        let minLength = min(self.size.width, self.size.height)
        let cropRect = CGRect(x: (self.size.width - minLength) / 2.0, y: (self.size.height - minLength) / 2.0, width: minLength, height: minLength)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: minLength, height: minLength)))
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(cgImage: cgImage)
        imageView.layer.cornerRadius = minLength / 2.0
        imageView.layer.masksToBounds = true
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizedImage(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
