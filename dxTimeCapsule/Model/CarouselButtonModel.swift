//
//  CarouselButtonModel.swift
//  AppleMapUIKit
//
//  Created by Djallil Elkebir on 2023-01-09.
//

import Foundation

enum ItemType {
    case home, work, add
    
    var icon: String {
        switch self {
        case .home:
            return "house"
        case .work:
            return "briefcase.fill"
        case .add:
            return "plus"
        }
    }
}

struct CarouselButtonModel: Hashable {
    let title: String
    let subtitle: String
    let type: ItemType

    private let identifier = UUID()
    
    init(title: String, subtitle: String, type: ItemType) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
    
    static let sampleData: [CarouselButtonModel] = [
        CarouselButtonModel(title: "Home", subtitle: "Add", type: .home),
        CarouselButtonModel(title: "Work", subtitle: "Add", type: .work),
        CarouselButtonModel(title: "Add", subtitle: "", type: .add)
        ]
        
}
