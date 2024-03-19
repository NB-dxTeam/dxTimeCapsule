import UIKit
import Photos

class PhotoCell: UICollectionViewCell {

    static let identifier = "PhotoCell"
    
    private let checkmarkImageView = UIImageView()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let selectedIndicator: UIView = {
         let view = UIView()
         view.backgroundColor = UIColor.clear // 선택되지 않은 상태의 배경색
         view.layer.borderColor = UIColor.white.cgColor
         view.layer.borderWidth = 2
         view.layer.cornerRadius = 15 // 원형 표시를 위한 반경 설정
         view.isHidden = true // 기본적으로 숨김 처리
         return view
     }()
    
    private let selectionNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isHidden = true // 기본적으로 숨김 처리
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(photoImageView)
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 커스텀 색상 설정을 위한 UIImage.SymbolConfiguration 생성
           let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
        let symbolImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)

        // Checkmark 이미지 뷰 설정
         checkmarkImageView.image = symbolImage
         checkmarkImageView.isHidden = true // 기본적으로 숨김
         contentView.addSubview(checkmarkImageView)
         checkmarkImageView.snp.makeConstraints { make in
             make.right.bottom.equalToSuperview().inset(8)
             make.width.height.equalTo(25)
         }
        
        addSubview(selectedIndicator)
        selectedIndicator.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(30) // 체크 표시 크기
        }
        
        selectedIndicator.addSubview(selectionNumberLabel)
        selectionNumberLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
     }
    
    override var isSelected: Bool {
        didSet {
            // Update visual state based on isSelected
            self.layer.borderWidth = isSelected ? 2 : 0
            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
          super.prepareForReuse()
          photoImageView.image = nil
          self.backgroundColor = .white
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
    
    func updateSelectionState(isSelected: Bool, selectionNumber: Int = 0) {
        selectedIndicator.isHidden = !isSelected
        selectionNumberLabel.isHidden = !isSelected
        if isSelected {
            selectionNumberLabel.text = "\(selectionNumber)"
        }
    }

 }
