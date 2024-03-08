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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(photoImageView)
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with asset: PHAsset, imageManager: PHCachingImageManager) {
        imageManager.requestImage(for: asset, targetSize: CGSize(width: frame.size.width, height: frame.size.height), contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                self.photoImageView.image = image
            }
        }
    }
}
