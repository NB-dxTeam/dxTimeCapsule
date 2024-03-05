import UIKit
import Combine

class BottomSheetControllerViewModel {
    
    enum Sections: CaseIterable {
        static var allCases: [Sections] = [.search ,.favorites([]), .recents([])]
        case search
        case favorites([CarouselButtonModel])
        case recents([HorizontalSearchModel])
    }
    
    private(set) var sections: [Sections] = []
    
    init() {
        generateSections(favorites: CarouselButtonModel.sampleData, recents: HorizontalSearchModel.sampleData)
    }
    
    private func generateSections(favorites: [CarouselButtonModel], recents: [HorizontalSearchModel]) {
        sections = []
        sections.append(.search)
        sections.append(.favorites(favorites))
        sections.append(.recents(recents))
    }
}
