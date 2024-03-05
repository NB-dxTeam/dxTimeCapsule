//
//  HorizontalSearchModel.swift
//  AppleMapsUI
//
//  Created by Djallil Elkebir on 2023-01-07.
//

import Foundation

struct HorizontalSearchModel: Identifiable, Equatable, Hashable {
    let id = UUID()
    private let identifier = UUID()
    let name: String
    let subtitle: String?
    let type: HorizontalSearchType

    // Sample Data
    static var sampleData: [HorizontalSearchModel] = [
        HorizontalSearchModel(
            name: "Apple Park",
            subtitle: "One Apple Park Way Cupertino",
            type: .special
        ),
        HorizontalSearchModel(
            name: "Microsoft Sillicon Valley Campus",
            subtitle: "1065 La Avenida St, Mountain View",
            type: .building
        ),
        HorizontalSearchModel(
            name: "Apple Park",
            subtitle: "One Apple Park Way Cupertino",
            type: .special
        )
    ]
}
