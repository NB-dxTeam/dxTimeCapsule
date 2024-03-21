import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    static let identifier = "PhotoCell"
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let selectedIndicator: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 15
        view.isHidden = true
        return view
    }()
    
    private let selectionNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(photoImageView)
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(selectedIndicator)
        selectedIndicator.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(30)
        }
        
        selectedIndicator.addSubview(selectionNumberLabel)
        selectionNumberLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with asset: PHAsset, imageManager: PHCachingImageManager, isSelected: Bool, selectionNumber: Int?, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat

        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
            DispatchQueue.main.async {
                self.photoImageView.image = image
            }
        }
        
        updateSelectionState(isSelected: isSelected, selectionNumber: selectionNumber)
    }

    func updateSelectionState(isSelected: Bool, selectionNumber: Int? = nil) {
        selectedIndicator.isHidden = !isSelected
        selectionNumberLabel.isHidden = !isSelected
        if let number = selectionNumber, isSelected {
            selectionNumberLabel.text = "\(number)"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        selectedIndicator.isHidden = true
        selectionNumberLabel.isHidden = true
    }
}
