import UIKit
import SnapKit
import PhotosUI
import Photos

class PhotoUploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - 속성 선언부
    
    var selectedLocation: CLLocationCoordinate2D?
    var selectedImage: [UIImage]? = [] {
        didSet {
            updateImageView()
        }
    }
    var thumnailImage: UIImage?
    
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
    private var backButton: UIButton!

    

    private let bannerLabel: UILabel = {
        let label = UILabel()
        label.text = "타임박스에 들어갈 사진을 선택해주세요! 첫번째 사진이 썸네일로 사용됩니다."
        label.font = .pretendardBold(ofSize: 16)
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
    
    private let moodPickerView = UIPickerView()
    
    private let friendsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50) // Adjust size as needed
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupUI()
        requestPhotoLibraryPermission()
        setupBannerLabel()
        setupPlaceholderLabel()
        fetchPhotos()
        updateNextButtonState()
        print("selectedLocation: \(String(describing: selectedLocation))")

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
        
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(hex: "#C82D6B")
        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        setupImageView()
        setupCollectionView()
        setupNextButton()
        setupBackButton()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // 이미지 뷰 설정
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // 네비게이션 바 아래에 배치되도록 수정
            make.left.right.equalToSuperview().inset(5)
            make.height.equalTo(view.snp.height).multipliedBy(0.5) // 전체 뷰의 높이의 50%
            make.width.equalTo(imageView.snp.height).multipliedBy(0.8) // 4:5 비율 유지
        }
    }
        
    private func setupCollectionView() {
         // 컬렉션 뷰 설정
         view.addSubview(collectionView)
         collectionView.snp.makeConstraints { make in
             make.top.equalTo(imageView.snp.bottom).offset(5)
             make.left.right.equalToSuperview().inset(5)
             make.bottom.equalTo(view.safeAreaLayoutGuide)
         }
     }
        
    private func setupNextButton() {
         // 'Next' 버튼 설정
         view.addSubview(nextButton)
         nextButton.snp.makeConstraints { make in
             make.centerX.equalToSuperview()
             make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
             make.height.equalTo(40)
             make.width.equalTo(200)
         }
         nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
     }
        
    private func setupBackButton() {
        // 'Back' 버튼 설정
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(40)
        }
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    
    private func setupPlaceholderLabel() {
        view.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(imageView) // imageView의 centerY에 맞추도록 수정
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
            case .denied:
                // 거부된 경우 처리
                // 사용자에게 앱 권한을 얻을 수 있는 방법을 안내하거나 적절한 경고를 표시합니다.
                break
            case .restricted:
                // 제한된 경우 처리
                // 사용자가 사진 라이브러리에 접근할 수 없는 경우에 대한 처리를 수행합니다.
                break
            case .limited:
                // 제한된 권한으로 제한된 경우 처리
                // 사용자에게 제한된 권한으로 앱을 사용하는 방법을 안내하거나 해당 제한사항을 고려합니다.
                break
            case .notDetermined:
                break
            @unknown default:
                // 알려지지 않은 다른 경우 처리
                // 앱에서 알 수 없는 새로운 권한 상태가 추가되면 해당 처리를 수행합니다.
                break
            }
        }
    }

    // 배너 라벨 설정 및 자동 숨김
    private func setupBannerLabel() {
        view.addSubview(bannerLabel)
        bannerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        // 텍스트 스타일 설정
        let attributedText = NSMutableAttributedString(string: "타임박스에 들어갈 사진을 선택해주세요!\n", attributes: [
            .font: UIFont.pretendardBold(ofSize: 16)!,
            .foregroundColor: UIColor.white
        ])
        
        attributedText.append(NSAttributedString(string: "첫번째 사진이 썸네일로 사용됩니다.", attributes: [
            .font: UIFont.pretendardBold(ofSize: 16)!,
            .foregroundColor: UIColor.white
        ]))
        
        bannerLabel.attributedText = attributedText
        bannerLabel.numberOfLines = 0 // 여러 줄 허용
        bannerLabel.textAlignment = .center // 가운데 정렬
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
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

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.placeholderLabel.isHidden = false 
        }

        allPhotos.enumerateObjects { (asset, index, _) in
            print("Photo at index \(index): \(asset.localIdentifier)")
            self.assets.append(asset)
        }

    }




    // 선택된 사진을 imageView에 표시
    private func selectAndDisplayImage(for asset: PHAsset) {
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    // 이미지가 유효한 경우에만 selectedImage 배열에 추가
                    self.selectedImage = [image]
                    self.imageView.image = image
                    // 썸네일 이미지 업데이트
                    self.thumnailImage = image
                }
            }
        }
    }

    
    private func updateSelectedImage() {
        guard let firstSelectedAsset = selectedAssets.first else {
            self.selectedImage = nil
            return
        }

        let targetSize = CGSize(width: imageView.frame.width * UIScreen.main.scale, height: imageView.frame.height * UIScreen.main.scale) // 화면의 해상도에 맞게 조정
        imageManager.requestImage(for: firstSelectedAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    self.selectedImage = [image]
                } else {
                    self.selectedImage = nil // 이미지가 없는 경우 selectedImage를 nil로 설정
                }
            }
        }
    }


    private func updateImageView() {
        if let firstImage = selectedImage?.first {
            imageView.image = firstImage
            imageView.isHidden = false
            placeholderLabel.isHidden = true
        } else {
            imageView.isHidden = true
            placeholderLabel.isHidden = false
        }
    }

    // MARK: - Button Actions

    // 'Next' 버튼 탭 시 동작
    @objc private func didTapNextButton() {
        
        guard let _ = selectedImage else {
            // 이미지가 선택되지 않은 경우 알림 표시
            showAlert(message: "사진을 선택해주세요!")
            return
        }
        
        let postWritingVC = PostWritingViewController()
        
        // 이미지를 선택한 경우에만 처리
        if let firstSelectedAsset = selectedAssets.first {
            // 이미지를 가져와 selectedImage 배열에 추가
            selectAndDisplayImage(for: firstSelectedAsset)
        }
        
        // selectedImage 배열을 PostWritingViewController로 전달
        postWritingVC.selectedImage = self.selectedImage!
        postWritingVC.thumnailImage = self.thumnailImage
        postWritingVC.selectedLocation = self.selectedLocation
        
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
    
    // MARK: - Helper Methods

    private func updateNextButtonState() {
        // 이미지가 선택되었는지 여부에 따라 'Next' 버튼 활성화/비활성화
        nextButton.isEnabled = selectedImage != nil
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        let isSelected = selectedAssets.contains(where: { $0 == asset })

        // 선택 순서 번호 계산
        let selectionNumber = isSelected ? selectedAssets.firstIndex(of: asset).map { $0 + 1 } : nil

        // 셀 크기 계산
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let cellSize = layout?.itemSize ?? CGSize(width: 100, height: 100) // 기본 크기
        let scale = UIScreen.main.scale // 화면의 스케일
        let targetSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)

        // 사진, 선택 상태, 선택 순서 번호, 타겟 크기로 셀 구성
        cell.configure(with: asset, imageManager: imageManager, isSelected: isSelected, selectionNumber: selectionNumber, targetSize: targetSize)

        return cell
    }


    
    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Emoji.emojis.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Emoji.emojis[row].description
    }
    
    
    
    // UICollectionViewDelegateFlowLayout
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
            selectedAssets.remove(at: selectedIndex)
        } else {
            selectedAssets.append(asset)
        }
        updateSelectedImage()
        collectionView.reloadData() // 콜렉션 뷰 갱신
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
    
    @objc private func backButtonTapped() {
         dismiss(animated: true, completion: nil)
     }
}




// MARK: - SwiftUI Preview
import SwiftUI

struct MainTabBarViewPreview22 : PreviewProvider {
    static var previews: some View {
        PhotoUploadViewController().toPreview()
    }
}
