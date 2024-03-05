//
//  CustomPresentationDetents.swift
//  AppleMapsUI
//
//  Created by Djallil Elkebir on 2023-01-07.
//

import SwiftUI

struct SmallDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Little trick to get the context to calculate the current sheet height
            NotificationCenter.default.post(name: .getContext, object: context)
        }
       return max(44, context.maxDetentValue * 0.1)
    }
}

struct MediumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Little trick to get the context to calculate the current sheet height
            NotificationCenter.default.post(name: .getContext, object: context)
        }
       return max(44, context.maxDetentValue * 0.5)
    }
}

struct LargeDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Little trick to get the context to calculate the current sheet height
            NotificationCenter.default.post(name: .getContext, object: context)
        }
       return max(44, context.maxDetentValue)
    }
}

extension PresentationDetent {
    static let small = Self.custom(SmallDetent.self)
    static let customMedium = Self.custom(MediumDetent.self)
    static let customLarge = Self.custom(LargeDetent.self)
}
