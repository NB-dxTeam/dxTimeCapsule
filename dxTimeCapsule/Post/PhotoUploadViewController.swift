import UIKit
import SnapKit
import PhotosUI
import Photos

class PhotoUploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {

    // MARK: - Properties
    
    private var selectedImage: UIImage?
     private let imageView = UIImageView()
     private let nextButton = UIButton(type: .system)
     private var assets: [PHAsset] = []
     private var selectedAssets: [PHAsset] = []
     private var imageManager = PHCachingImageManager()
     
    private let bannerLabel: UILabel = {
        let label = UILabel()
        label.text = "타임박스에 들어갈 사진을 선택해주세요!"
        label.font = .pretendardBold(ofSize: 16)
        label.textColor = UIColor(hex: "#D53369")
        label.backgroundColor = .white.withAlphaComponent(0.85)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()

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
        setupBannerLabel()

        // Add pan gesture recognizer to detect downward drag
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextButton.setCustom1()
    }
    
    private func setupProperties() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 8
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
    
    private func setupBannerLabel() {
        view.addSubview(bannerLabel)
        bannerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }

        // Automatically hide the banner after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5) {
                self.bannerLabel.alpha = 0
                
            } completion: { _ in
                self.bannerLabel.removeFromSuperview()
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
            // 뷰 로드 시 첫 번째 사진을 이미지 뷰에 자동으로 표시
            if let firstAsset = self.assets.first {
                self.selectedAssets.append(firstAsset) // 첫 번째 사진을 선택된 상태로 추가
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
        if #available(iOS 15.0, *) {
            if let sheet = postWritingVC.sheetPresentationController {
                sheet.detents = [.medium()] // Adjust to [.medium()] or create custom detent for desired height
                // Use `largestUndimmedDetentIdentifier` to allow interaction with the background
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        } else {
            // Fallback on earlier versions: Adjust `modalPresentationStyle` as needed or use custom presentation controllers
            postWritingVC.modalPresentationStyle = .pageSheet
        }
        present(postWritingVC, animated: true, completion: nil)
    }

    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            fatalError("Unable to dequeue PhotoCell")
        }
        let asset = assets[indexPath.item]
        cell.configure(with: asset, imageManager: imageManager)

        // 선택된 아이템에 대해 시각적으로 표시 (예: 체크 마크 추가)
        cell.updateSelectionState(isSelected: selectedAssets.contains(asset))

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

        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index) // 선택 해제
        } else {
            selectedAssets.append(asset) // 선택
        }

        // 첫 번째 선택된 사진을 이미지 뷰에 표시
        if let firstAsset = selectedAssets.first {
            selectAndDisplayImage(for: firstAsset)
        } else {
            imageView.image = nil // 선택된 사진이 없으면 이미지 뷰 클리어
        }

        collectionView.reloadItems(at: [indexPath]) // 선택 상태 변경으로 인한 셀 업데이트
    }


    private func updateImageView(with asset: PHAsset) {
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                self.imageView.image = image // 첫 번째 사진을 이미지 뷰에 표시
            }
        }
    }
    
    // MARK: - Pan Gesture Handler
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                // Move the view down with the drag
                view.frame.origin.y = translation.y
            }
        case .ended:
            if velocity.y > 0 {
                // Dismiss the modal if dragged downward with enough velocity
                dismiss(animated: true, completion: nil)
            } else {
                // Reset the view position if drag distance is less than 100 points
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        default:
            break
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
