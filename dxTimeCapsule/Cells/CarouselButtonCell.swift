import UIKit

class CarouselButtonCell: UICollectionViewCell {
    
    // MARK: - ViewModel
    
    struct ViewModel {
        let type: ItemType
        let title: String
        let subtitle: String?
    }
    // MARK: - UI Component(s)
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center
        
        return stack
    }()
    
    private lazy var nestedInsetVStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        stack.backgroundColor = .white
        stack.layer.cornerRadius = 30
        
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption2)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 6
        image.clipsToBounds = true
        image.tintColor = .systemBlue
        return image
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
    static func dequeueReusableCell(collectionView: UICollectionView, for indexPath: IndexPath, viewModel: ViewModel) -> CarouselButtonCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? CarouselButtonCell else { fatalError()}
        cell.configureWith(viewModel)
        return cell
    }
}

// MARK: UI

extension CarouselButtonCell {
    private func setupConstraint() {
        configureStackView()
    }
    
    private func configureStackView() {
        contentView.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
        
        vStack.addArrangedSubviews([
            nestedInsetVStack,
            titleLabel,
            subtitleLabel
        ])
        
        nestedInsetVStack.addArrangedSubview(imageView)
        
        NSLayoutConstraint.activate([
            nestedInsetVStack.heightAnchor.constraint(equalToConstant: 60),
            nestedInsetVStack.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - ViewModel Config

extension CarouselButtonCell {
    
    private func configureWith(_ viewModel: ViewModel) {
        let configuration = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .title1))
        imageView.image = UIImage(systemName: viewModel.type.icon,withConfiguration: configuration)
        titleLabel.text = viewModel.title
        if let subtitle = viewModel.subtitle {
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.text = ""
        }
    }
}
