import UIKit
import SnapKit
import PhotosUI
import Photos

class PhotoUploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    
    private var selectedImage: UIImage?
     private let imageView = UIImageView()
     private let nextButton = UIButton(type: .system)
     private var assets: [PHAsset] = []
     private var selectedAssets: [PHAsset] = []
     private var imageManager = PHCachingImageManager()
     private let titleLabel = UILabel()
     
     private lazy var collectionView: UICollectionView = {
         let layout = UICollectionViewFlowLayout()
         layout.minimumInteritemSpacing = 3
         layout.minimumLineSpacing = 3
         let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
         cv.backgroundColor = .white
         cv.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
         cv.dataSource = self
         cv.delegate = self
         return cv
     }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupUI()
        requestPhotoLibraryPermission()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextButton.backgroundColor = UIColor(hex: "#D53369").withAlphaComponent(0.8)
    }
    
    private func setupProperties() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
    }
    
    // MARK: - Setup UI
    

    private func setupUI() {
        view.backgroundColor = .white

        // 상단 이미지 뷰 설정 - 1:1 비율 유지
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(5)
            make.height.equalTo(imageView.snp.width) // 이 부분을 수정하여 높이를 너비와 동일하게 설정
        }


        // 컬렉션 뷰 설정
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(5)
            make.bottom.equalTo(view.safeAreaLayoutGuide) // 필요에 따라 조정할 수 있음
        }
        
        // 'Next' 버튼 설정
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(80)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    // MARK: - Other Methods
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.fetchPhotos()
                }
            case .denied, .restricted, .notDetermined:
                // Handle denied or restricted
                break
            @unknown default:
                break
            }
        }
    }
    
    private func fetchPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allPhotos = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        
        assets = []
        allPhotos.enumerateObjects { (asset, _, _) in
            self.assets.append(asset)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            // Automatically select and display the first photo in the assets array
            if let firstAsset = self.assets.first {
                self.selectAndDisplayImage(for: firstAsset)
            }
        }
    }
    
    private func selectAndDisplayImage(for asset: PHAsset) {
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                self.selectedImage = image
                self.imageView.image = image // 첫 번째 사진을 이미지 뷰에 표시
            }
        }
    }
    
    // MARK: - Action
    
    @objc private func didTapNextButton() {
        let postWritingVC = PostWritingViewController()
        postWritingVC.modalPresentationStyle = .pageSheet
        present(postWritingVC, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        let asset = assets[indexPath.item]
        cell.configure(with: asset, imageManager: imageManager)
        
        // Update cell's visual state based on selection
        cell.isSelected = selectedAssets.contains(asset)
        // Optionally, customize the cell further to reflect selection state visually
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let padding: CGFloat = 5 // 여백 값 설정

        // 총 너비에서 좌우 인셋을 빼고, 아이템 간의 간격(아이템 수 - 1)을 고려하여 사용 가능한 너비를 계산
        let totalPaddingSpace = padding * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right) - totalPaddingSpace
        let widthPerItem = floor(availableWidth / itemsPerRow)

        return CGSize(width: widthPerItem, height: widthPerItem) // 1:1 비율로 셀 크기 설정
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        
        // Toggle selection
        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
        } else {
            selectedAssets.append(asset)
        }
        
        // Update UI based on the first selected asset
        if let firstAsset = selectedAssets.first {
            selectAndDisplayImage(for: firstAsset)
        } else {
            imageView.image = nil // Clear the image view if no assets are selected
        }
        
        collectionView.reloadItems(at: [indexPath]) // Refresh the cell to show selection state
    }


    private func updateImageView(with asset: PHAsset) {
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                self.imageView.image = image // 첫 번째 사진을 이미지 뷰에 표시
            }
        }
    }

}

// MARK: - SwiftUI Preview
//import SwiftUI
//
//struct MainTabBarViewPreview5 : PreviewProvider {
//    static var previews: some View {
//        PhotoUploadViewController().toPreview()
//    }
//}
