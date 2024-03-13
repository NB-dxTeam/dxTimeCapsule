//
//  HomeViewControllerModel.swift
//  dxTimeCapsule
//
//  Created by t2023-m0028 on 3/12/24.
//

import Foundation
import UIKit

enum VerticalAlignment {
    case top
    case middle
    case bottom
}

class VerticallyAlignedLabel: UILabel {
    var verticalAlignment: VerticalAlignment = .middle {
        didSet {
            setNeedsDisplay()
        }
    }

    override func drawText(in rect: CGRect) {
        guard let textString = text else {
            super.drawText(in: rect)
            return
        }

        let attributedText = NSAttributedString(string: textString, attributes: [
            NSAttributedString.Key.font: font as Any,
            NSAttributedString.Key.foregroundColor: textColor as Any
        ])

        var newRect = rect
        let textSize = attributedText.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size

        switch verticalAlignment {
        case .top:
            newRect.size.height = textSize.height
        case .middle:
            newRect.origin.y += (newRect.size.height - textSize.height) / 2
            newRect.size.height = textSize.height
        case .bottom:
            newRect.origin.y += newRect.size.height - textSize.height
            newRect.size.height = textSize.height
        }

        super.drawText(in: newRect)
    }
}
