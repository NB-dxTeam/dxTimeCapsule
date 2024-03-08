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
    
    override func prepareForReuse() {
          super.prepareForReuse()
          photoImageView.image = nil
          self.backgroundColor = .white
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with asset: PHAsset, imageManager: PHCachingImageManager) {
         // 비동기 이미지 로딩 시 재사용 문제를 방지하기 위해 PHImageRequestOptions 설정 추가
         let options = PHImageRequestOptions()
         options.isNetworkAccessAllowed = true // 네트워크를 통한 이미지 다운로드 허용
         options.deliveryMode = .highQualityFormat // 고품질 이미지 요청
         
         imageManager.requestImage(for: asset, targetSize: CGSize(width: frame.size.width, height: frame.size.height), contentMode: .aspectFill, options: options) { image, _ in
             DispatchQueue.main.async {
                 self.photoImageView.image = image
             }
         }
        
     }
    
    override var isSelected: Bool {
        didSet {
            // Update visual state based on isSelected
            self.layer.borderWidth = isSelected ? 2 : 0
            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : nil
        }
    }
 }
