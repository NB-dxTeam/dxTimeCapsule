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
            name: "애플 파크",
            subtitle: "One Apple Park Way Cupertino",
            type: .special
        ),
        HorizontalSearchModel(
            name: "Microsoft 실리콘 밸리 캠퍼스",
            subtitle: "1065 라 아베니다 St, 마운틴 뷰",
            type: .building
        )
    ]
}
