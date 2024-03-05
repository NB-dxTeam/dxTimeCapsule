import UIKit

class HorizontalSearchCell: UICollectionViewCell {
    
    // MARK: - ViewModel
    
    struct ViewModel {
        let type: HorizontalSearchType
        let name: String
        let subtitle: String?
        let showSeparator: Bool
        
        init(type: HorizontalSearchType, name: String, subtitle: String?, showSeparator: Bool = true) {
            self.type = type
            self.name = name
            self.subtitle = subtitle
            self.showSeparator = showSeparator
        }
    }
    // MARK: - UI Component(s)
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .leading
        
        return stack
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .leading
        
        return stack
    }()
    
    private lazy var nestedInsetVStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 5, left: 5, bottom: 5, right: 5)
        stack.backgroundColor = .white
        stack.layer.cornerRadius = 15
        
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 6
        image.clipsToBounds = true
        image.tintColor = .white
        image.layer.cornerRadius = 15
        return image
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    // MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - function(s)
    static func dequeueReusableCell(collectionView: UICollectionView, for indexPath: IndexPath, viewModel: ViewModel) -> HorizontalSearchCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? HorizontalSearchCell else { fatalError()}
        cell.configureWith(viewModel)
        return cell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        separator.removeFromSuperview()
    }
}

// MARK: UI

extension HorizontalSearchCell {
    
    private func setupStyle() {
        contentView.backgroundColor = .white
    }
    
    private func setupConstraint() {
        configureStackView()
    }
    
    private func configureStackView() {
        contentView.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
        ])
        
        hStack.addArrangedSubviews([
            nestedInsetVStack,
            vStack
        ])
        
        nestedInsetVStack.addArrangedSubview(imageView)
        
        vStack.addArrangedSubviews([
            titleLabel,
            subtitleLabel
        ])
        
        NSLayoutConstraint.activate([
            nestedInsetVStack.heightAnchor.constraint(equalToConstant: 30),
            nestedInsetVStack.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func addSeparator() {
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: - ViewModel Config

extension HorizontalSearchCell {
    
    private func configureWith(_ viewModel: ViewModel) {
        let configuration = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .callout))
        imageView.image = UIImage(systemName: viewModel.type.icon, withConfiguration: configuration)
        titleLabel.text = viewModel.name
        if let subtitle = viewModel.subtitle {
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.text = ""
        }
        
        if viewModel.type == .special {
            nestedInsetVStack.backgroundColor = .purple
        } else {
            nestedInsetVStack.backgroundColor = .systemGray
        }
        
        if viewModel.showSeparator {
            addSeparator()
        }
    }
}
