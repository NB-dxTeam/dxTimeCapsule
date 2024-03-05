import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {
    
    // MARK: - Components
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.allowsMultipleSelection = true
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    // MARK: - Stored Properties
    
    private let viewModel: BottomSheetControllerViewModel
    
    private var observer: NSKeyValueObservation?
    
    // MARK: - Life Cycle
    
    init(viewModel: BottomSheetControllerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        configureCollectionViewWithSnapKit()
        
        if let sheetController = self.presentationController as? UISheetPresentationController {
            sheetController.detents = [.small, .medium(), .large()]
            sheetController.prefersEdgeAttachedInCompactHeight = true
            
            // MARK: - Really important to keep the user interaction possible with the map buttons
            sheetController.largestUndimmedDetentIdentifier = .medium
        }
        self.isModalInPresentation = true
        configureCollectionView()
        registerCells()
        setObservers()
    }
    
    private func configureCollectionViewWithSnapKit() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            // 여기를 수정합니다. 하단 여백을 뷰의 safeArea의 하단과 연결합니다.
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50) // 예시로 -50을 사용했지만, 필요에 따라 조정하세요.
        }
    }
    deinit {
        observer?.invalidate()
    }
}

// MARK: - UI

extension BottomSheetViewController {
    
    private func setupStyle() {
        view.backgroundColor = .secondarySystemBackground
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
    }

    

    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout {[weak self] (section, _) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            switch self.viewModel.sections[section] {
            case .favorites:
                return self.generateHorizontalButtonLayout()
            case .recents:
                return self.generateListLayout()
            case .search:
                return self.generateSearchHeaderLayout()
            }
        }
        
        return layout
    }
    
    private func generateSearchHeaderLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        return section
    }
    
    private func generateHorizontalButtonLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .estimated(80)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(20)
        
        group.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(20)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 10
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func generateListLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(20)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
}

// MARK: - CollectionView Data Source

extension BottomSheetViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func registerCells() {
        CarouselButtonCell.register(to: collectionView)
        HorizontalSearchCell.register(to: collectionView)
        SearchBarCell.register(to: collectionView)
        ListStyleCollectionViewHeader.register(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, to: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.sections[section] {
        case .favorites(let buttons):
            return buttons.count
        case .recents(let searches):
            return searches.count
        case .search:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.sections[indexPath.section] {
        case .favorites(let buttons):
            let button = buttons[indexPath.row]
            return CarouselButtonCell.dequeueReusableCell(collectionView: collectionView, for: indexPath, viewModel: .init(type: button.type, title: button.title, subtitle: button.subtitle))
        case .recents(let searches):
            let search = searches[indexPath.row]
            return HorizontalSearchCell.dequeueReusableCell(collectionView: collectionView, for: indexPath, viewModel: .init(type: search.type, name: search.name, subtitle: search.subtitle, showSeparator: !(search == searches.last)))
        case .search:
            return SearchBarCell.dequeueReusableCell(collectionView: collectionView, for: indexPath, viewModel: .init(profilPicture: UIImage(named: "animoji")))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch viewModel.sections[indexPath.section] {
        case .favorites(_):
            return ListStyleCollectionViewHeader.dequeueReusableCell(collectionView: collectionView, for: indexPath, viewModel: .init(title: "Favorites"), kind: UICollectionView.elementKindSectionHeader)
        case .recents(_):
            return ListStyleCollectionViewHeader.dequeueReusableCell(collectionView: collectionView, for: indexPath, viewModel: .init(title: "Recents"), kind: UICollectionView.elementKindSectionHeader)
        case .search:
            return UICollectionReusableView()
        }
    }
    
    
}

// MARK: - Delegate

extension BottomSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // do something
    }
}

// MARK: Custom Sheet Size
extension UISheetPresentationController.Detent {
    static var small: UISheetPresentationController.Detent {
        Self.custom { context in
            return context.maximumDetentValue * 0.25
        }
    }

}

// MARK: - Observer(s)

extension BottomSheetViewController {
    private func setObservers() {
        observer = observe(
            \.view?.frame,
            options: [.old, .new]
        ) { object, change in
            guard let height = change.newValue??.height else { return }
            NotificationCenter.default.post(name: .bottomSheetHeight, object: height)
        }
    }
}


// MARK: - Preview
import SwiftUI

struct MainTabBarViewPreview1 : PreviewProvider {
    static var previews: some View {
        MainTabBarView().toPreview()
    }
}
