import UIKit
import SnapKit
import PhotosUI
import Photos

class PhotoUploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {

    // MARK: - 속성 선언부
    private var selectedImage: UIImage? {
        didSet {
            updateImageView()
        }
    }
    
    private let placeholderLabel: UILabel = {
         let label = UILabel()
         label.text = "사진을 선택해주세요"
         label.textColor = .gray
         label.textAlignment = .center
         label.isHidden = true // 기본적으로 숨김 처리
         return label
     }()
    
    private let imageView = UIImageView()
    private let nextButton = UIButton(type: .system)
    private var assets: [PHAsset] = []
    private var selectedAssets: [PHAsset] = []
    private var imageManager = PHCachingImageManager()
    private var closeButton: UIButton!

    

    private let bannerLabel: UILabel = {
        let label = UILabel()
        label.text = "타임박스에 들어갈 사진을 선택해주세요! 첫번째 사진이 썸네일로 사용됩니다."
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(hex: "#C82D6B").withAlphaComponent(0.8)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.numberOfLines = 0 // 여러 줄 표시를 위해 설정
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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupUI()
        requestPhotoLibraryPermission()
        setupBannerLabel()
        setupPlaceholderLabel()
        setupImageView()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    // UI 속성 설정
    private func setupProperties() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        nextButton.setTitle("다음", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        nextButton.backgroundColor = UIColor(hex: "#C82D6B")
        nextButton.layer.cornerRadius = 16
        nextButton.layer.shadowOpacity = 0.3
        nextButton.layer.shadowRadius = 5
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        closeButton = UIButton(type: .system)
        closeButton.setTitle("뒤로", for: .normal)
        closeButton.tintColor = UIColor(hex: "#C82D6B")
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup UI
       private func setupUI() {
           view.backgroundColor = .white



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
               make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
               make.height.equalTo(40)
               make.width.equalTo(200)
           }
           nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
           
           view.addSubview(closeButton)
           closeButton.snp.makeConstraints { make in
               make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
               make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
               make.width.height.equalTo(40)
           }
       }
    
    private func setupPlaceholderLabel() {
        view.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
    }

    // 사진 라이브러리 권한 요청
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

    private func setupImageView() {
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // 이미지뷰 제약 설정
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(5)
            make.height.equalTo(view.snp.height).multipliedBy(0.5) // 전체 뷰의 높이의 50%
            make.width.equalTo(imageView.snp.height).multipliedBy(0.8) // 4:5 비율 유지

        }
    }

    // 배너 라벨 설정 및 자동 숨김
    private func setupBannerLabel() {
        view.addSubview(bannerLabel)
        bannerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        bannerLabel.sizeToFit() // 내용에 맞게 크기 조절


        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5) {
                self.bannerLabel.alpha = 0
            } completion: { _ in
                self.bannerLabel.removeFromSuperview()
            }
        }
    }

    // 사진 데이터 가져오기
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


    
    // 선택된 사진을 imageView에 표시
    private func selectAndDisplayImage(for asset: PHAsset) {
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                self.selectedImage = image
                self.imageView.image = image
            }
        }
    }

    // 'Next' 버튼 탭 시 동작
    @objc private func didTapNextButton() {
        let postWritingVC = PostWritingViewController()
        // iOS 15 이상에서 모달의 부분적인 높이 조절
        if #available(iOS 15.0, *) {
            postWritingVC.modalPresentationStyle = .pageSheet
            if let sheet = postWritingVC.sheetPresentationController {
                sheet.detents = [.medium()] // 모달 높이를 중간 크기로 설정
            }
        } else {
            // iOS 15 미만에서는 기본 modalPresentationStyle 사용
            postWritingVC.modalPresentationStyle = .automatic
        }
        // 모달 표시 중복 방지를 위해 현재 표시 중인 ViewController 확인
        if self.presentedViewController == nil {
            self.present(postWritingVC, animated: true, completion: nil)
        }
    }
    // 'Close' 버튼 탭 시 동작
    @objc private func closeButtonTapped() {
         dismiss(animated: true, completion: nil)
     }
    
    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of items in section: \(assets.count)")
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            fatalError("Unable to dequeue PhotoCell")
        }
        let asset = assets[indexPath.item]

        // 선택 상태 확인
        let isSelected = selectedAssets.contains(asset)

        // 선택 순서 번호 계산
        let selectionNumber = isSelected ? selectedAssets.firstIndex(of: asset).map { $0 + 1 } : nil

        // 사진, 선택 상태, 선택 순서 번호로 셀 구성
        cell.configure(with: asset, imageManager: imageManager, isSelected: isSelected, selectionNumber: selectionNumber)

        return cell
    }

    
    // UICollectionViewDelegateFlowLayout 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let padding: CGFloat = 5 // 여백 값 설정

        // 총 너비에서 좌우 인셋을 빼고, 아이템 간의 간격(아이템 수 - 1)을 고려하여 사용 가능한 너비를 계산
        let totalPaddingSpace = padding * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right) - totalPaddingSpace
        let widthPerItem = floor(availableWidth / itemsPerRow)

        return CGSize(width: widthPerItem, height: widthPerItem) // 1:1 비율로 셀 크기 설정
    }

    // 사용자가 사진을 선택했을 때의 처리
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
    
        if let selectedIndex = selectedAssets.firstIndex(of: asset) {
            // 이미 선택된 사진을 취소하는 경우
            selectedAssets.remove(at: selectedIndex)
        } else {
            // 새로운 사진을 선택하는 경우
            selectedAssets.append(asset)
        }
    
        // 선택된 사진 배열의 첫 번째 항목을 사용하여 selectedImage 업데이트
        updateSelectedImage()
    
        // 선택 상태가 변경된 후 전체 콜렉션 뷰를 갱신
        collectionView.reloadData()
    }

    func updateSelectedImage() {
        guard let firstSelectedAsset = selectedAssets.first else {
            // 선택된 사진이 없는 경우
            self.selectedImage = nil
            return
        }
    
        // 선택된 첫 번째 사진을 사용하여 selectedImage 업데이트
        imageManager.requestImage(for: firstSelectedAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                self.selectedImage = image
            }
        }
    }
    
    private func updateImageView() {
        if let selectedImage = selectedImage {
            imageView.image = selectedImage
            imageView.isHidden = false
            placeholderLabel.isHidden = true
        } else {
            imageView.isHidden = true
            placeholderLabel.isHidden = false
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
import SwiftUI

struct MainTabBarViewPreview22 : PreviewProvider {
    static var previews: some View {
        PhotoUploadViewController().toPreview()
    }
}
