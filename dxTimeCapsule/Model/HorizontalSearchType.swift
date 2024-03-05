//
//  HorizontalSearchType.swift
//  AppleMapsUI
//
//  Created by Djallil Elkebir on 2023-01-07.
//

import Foundation

enum HorizontalSearchType: CaseIterable {
    case search
    case building
    case adresse
    case special
    
    var icon: String {
        switch self {
        case .search:
            return "magnifyingglass"
        case .building:
            return "building.2"
        case .adresse:
            return "arrow.left"
        case .special:
            return "star.fill"
        }
    }
}
