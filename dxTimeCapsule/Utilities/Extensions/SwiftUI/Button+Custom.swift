//
//  Button+Custom.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/14/24.
//

import SwiftUI

extension Button {
    
    // Instagram Style
    func setInstagramStyle() -> some View {
        self
            .padding()
            .foregroundColor(.white)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5137254902, green: 0.2274509804, blue: 0.7058823529, alpha: 1)), Color(#colorLiteral(red: 0.9921568627, green: 0.1137254902, blue: 0.1137254902, alpha: 1)), Color(#colorLiteral(red: 0.9882352941, green: 0.6901960784, blue: 0.2705882353, alpha: 1))]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(10)
    }
}
