import UIKit

class SearchBarCell: UICollectionViewCell {
    
    // MARK: - ViewModel
    
    struct ViewModel {
        let profilPicture: UIImage?
    }
    // MARK: - UI Component(s)
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .center
        
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 6
        image.clipsToBounds = true
        image.layer.cornerRadius = 15
        image.backgroundColor = .white
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = .secondarySystemBackground
        return searchBar
        
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
    static func dequeueReusableCell(collectionView: UICollectionView, for indexPath: IndexPath, viewModel: ViewModel) -> SearchBarCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? SearchBarCell else { fatalError()}
        cell.configureWith(viewModel)
        return cell
    }
}

// MARK: UI

extension SearchBarCell {
    private func setupConstraint() {
        configureStackView()
    }
    
    private func configureStackView() {
        contentView.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        hStack.addArrangedSubviews([
            searchBar,
            imageView
        ])
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
}

// MARK: - ViewModel Config

extension SearchBarCell {
    
    private func configureWith(_ viewModel: ViewModel) {
        imageView.image = viewModel.profilPicture
    }
}
