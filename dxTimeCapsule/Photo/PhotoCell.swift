import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    private var assetIdentifier: String?
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
        self.assetIdentifier = asset.localIdentifier // 현재 셀에 로드해야 할 이미지 식별자 저장
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        // Adjust targetSize to match the imageView's size or the screen resolution
        let adjustedTargetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height) // Adjust appropriately
        
        imageManager.requestImage(for: asset, targetSize: adjustedTargetSize, contentMode: .aspectFill, options: options) { [weak self] image, _ in
            DispatchQueue.main.async {
                // 이미지 로딩 완료 시 현재 셀이 로드해야 할 이미지인지 확인
                if self?.assetIdentifier == asset.localIdentifier {
                    self?.photoImageView.image = image
                }
            }
        }
        
        // Update selection state
        updateSelectionState(isSelected: isSelected, selectionNumber: selectionNumber)
        
        // Show selection number label
        selectionNumberLabel.isHidden = !isSelected // 숨김 처리 해제
        selectionNumberLabel.text = isSelected ? "\(selectionNumber ?? 0)" : nil // 선택된 경우 숫자 표시
    }

    func updateSelectionState(isSelected: Bool, selectionNumber: Int?) {
        selectedIndicator.isHidden = !isSelected
        selectionNumberLabel.isHidden = !isSelected
        if let number = selectionNumber {
            selectionNumberLabel.text = "\(number)"
        } else {
            selectionNumberLabel.text = nil
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        selectedIndicator.isHidden = true
        selectionNumberLabel.isHidden = true
    }
}
