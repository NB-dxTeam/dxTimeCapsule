import UIKit

class ListStyleCollectionViewHeader: UICollectionViewCell {
    
    // MARK: - ViewModel
    
    struct ViewModel {
        let title: String
    }
    // MARK: - UI Component(s)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - function(s)
    static func dequeueReusableCell(collectionView: UICollectionView, for indexPath: IndexPath, viewModel: ViewModel, kind: String) -> ListStyleCollectionViewHeader {
        guard let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? ListStyleCollectionViewHeader else { fatalError() }
        cell.configureWith(viewModel)
        return cell
    }
}

// MARK: UI

extension ListStyleCollectionViewHeader {
    
    private func setupStyle() {
        contentView.backgroundColor = .white
    }
    
    private func setupConstraint() {
        configureStackView()
    }
    
    private func configureStackView() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}

// MARK: - ViewModel Config

extension ListStyleCollectionViewHeader {
    private func configureWith(_ viewModel: ViewModel) {
        titleLabel.text = viewModel.title
    }
}
