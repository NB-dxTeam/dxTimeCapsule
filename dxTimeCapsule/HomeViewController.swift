//
//  HomeViewController.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 2/23/24.
//

import UIKit
import SwiftUI
import SnapKit
import FirebaseFirestore
import FirebaseAuth
import SwiftfulLoadingIndicators

class HomeViewController: UIViewController {
    
    private var loadingIndicator: some View {
        LoadingIndicator(animation: .text, size: .large, speed: .normal)
    }
    
    // MARK: - Properties
    var documentId: String?
    // 메인 타임캡슐 이미지 배열
    let mainTCImages = [UIImage(named: "IMG1"), UIImage(named: "IMG2"), UIImage(named: "IMG3"), UIImage(named: "IMG4")]
    
    // 현재 표시 중인 이미지의 인덱스
    var currentImageIndex = 0
    
    // 메인 타임캡슐 그림자
    let mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 4)
        view.layer.shadowRadius = 7
        return view
    }()
    
    // MARK: - IBOutlet properties
    
    // 메인 타임캡슐 이미지뷰
    let mainTCImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "location"))
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Other UI properties
    
    // 장소 레이블
    let locationNameLabel: UILabel = {
        let label = UILabel()
        label.text = "서서울호수공원"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    // 위치 레이블
    let locationAddressLabel: VerticallyAlignedLabel = {
        let label = VerticallyAlignedLabel()
        label.text = "서울시 양천구 신월동"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.verticalAlignment = .top // 수직 정렬 설정
        return label
    }()
    
    // D-Day 레이블
    let dDayLabel: VerticallyAlignedLabel = {
        let label = VerticallyAlignedLabel()
        label.text = "D-DAY"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .red
        label.textAlignment = .right
        label.verticalAlignment = .top
        return label
    }()
    
    // MARK: - StackViews
    
    // 장소정보 스택뷰
    lazy var locationInforStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.addArrangedSubview(self.locationNameLabel)
        stackView.addArrangedSubview(self.dDayLabel)
        return stackView
    }()
    
    // DuestTC 스택뷰
    lazy var duestTCInforStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.addArrangedSubview(self.locationInforStackView)
        stackView.addArrangedSubview(self.locationAddressLabel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(duestTCStackViewTapped))
        stackView.addGestureRecognizer(tapGesture)
        stackView.isUserInteractionEnabled = true
        
        return stackView
    }()
    
    // MARK: - No Main TC
    
    // noMainTC 라벨
    let noMainTCLabel: VerticallyAlignedLabel = {
        let attributedString = NSMutableAttributedString(string: "더이상 열어볼 캡슐이 없어요😭\n", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 20)
        ])
        attributedString.append(NSAttributedString(string: "+를 눌러 계속해서 시간여행을 떠나보세요!", attributes: [
            .font: UIFont.systemFont(ofSize: 15)
        ]))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5 // 두줄 사이 간격 조절
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length)) // 간격 적용
        
        let label = VerticallyAlignedLabel()
        label.numberOfLines = 2
        label.textColor = .black
        label.attributedText = attributedString
        label.verticalAlignment = .top
        return label
    }()
    
    // noMainTC 버튼
    let addTCButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus.app")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = UIColor(red: 213/255.0, green: 51/255.0, blue: 105/255.0, alpha: 1.0)
        button.setBackgroundImage(image, for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    // noMainTC 스택뷰
    lazy var noMainTCStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.addArrangedSubview(self.noMainTCLabel)
        stackView.addArrangedSubview(self.addTCButton)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewTC))
        stackView.addGestureRecognizer(tapGesture)
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    // MARK: - Buttons
    
    // 열어본 타임캡슐 버튼
    let openedTCButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "duestTC")?.withRenderingMode(.alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openedTCButtonTapped), for: .touchUpInside)
        
        // 버튼 내에 UILabel 추가
        let titleLabel = UILabel()
        titleLabel.text = "Saved\nmemories"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // UILabel을 버튼에 추가
        button.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return button
    }()
    
    let openedButtonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 4)
        view.layer.shadowRadius = 7
        return view
    }()
    
    // 다가오는 타임캡슐 버튼
    let upcomingTCButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "upcomingTC")?.withRenderingMode(.alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(upcomingTCButtonTapped), for: .touchUpInside)
        
        // 버튼 내에 UILabel 추가
        let titleLabel = UILabel()
        titleLabel.text = "Upcoming\nmemories"
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // UILabel을 버튼에 추가
        button.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return button
    }()
    
    let upcomingButtonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 4)
        view.layer.shadowRadius = 7
        return view
    }()
    
    // MARK: - Other UI properties
    
    // 버튼 스택뷰
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [openedButtonContainerView, upcomingButtonContainerView])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually // 크기를 동일하게 설정
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addLogoToNavigationBar()
        fetchTimeCapsuleData()
        configureUI()
    }
    
    // MARK: - Helpers
    
    private func addLogoToNavigationBar() {
        // 로고 이미지 설정
        let logoImage = UIImage(named: "App_Logo")
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        
        let addFriendsButton: UIButton = {
            let button = UIButton(type: .system)
            let image = UIImage(systemName: "person.badge.plus")?.withRenderingMode(.alwaysTemplate) // 이미지를 템플릿 모드로 설정
            button.setBackgroundImage(image, for: .normal)
            button.clipsToBounds = true
            button.tintColor = UIColor.systemGray
            button.addTarget(self, action: #selector(addFriendsButtonTapped), for: .touchUpInside)
            button.isUserInteractionEnabled = true
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            return button
        }()
        
        let imageSize = CGSize(width: 120, height: 40)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: -5), size: imageSize)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        containerView.addSubview(imageView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
        
        // Add a space before adding the addFriendsButton
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 20 // Adjust the width of the space as needed
        
        navigationItem.rightBarButtonItems = [space, UIBarButtonItem(customView: addFriendsButton)]
    }

    // MARK: - UI Configuration
    
    private func configureUI(){
        
        // 메인 타임캡슐 그림자 추가
        view.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.15/6.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(offset)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(2.0/6.0)
        }
        
        // mainTCImageView를 maincontainerView에 추가
        mainContainerView.addSubview(mainTCImageView)
        mainTCImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mainTCImageViewTapped))
        mainTCImageView.addGestureRecognizer(tapGesture)
        
        view.addSubview(duestTCInforStackView)
        duestTCInforStackView.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.15/6.0)
            make.top.equalTo(mainContainerView.snp.bottom).offset(offset)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalToSuperview().multipliedBy(0.8/6.0)
        }
        
        view.addSubview(noMainTCStackView)
        noMainTCStackView.snp.makeConstraints { make in
            let offset = UIScreen.main.bounds.height * (0.15/6.0)
            make.top.equalTo(mainContainerView.snp.bottom).offset(offset)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalToSuperview().multipliedBy(0.8/6.0)
        }
        noMainTCStackView.addArrangedSubview(noMainTCLabel)
        noMainTCLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }
        
        noMainTCStackView.addArrangedSubview(addTCButton)
        addTCButton.snp.makeConstraints { make in
            make.width.equalTo(addTCButton.snp.height)
            make.height.equalTo(noMainTCStackView.snp.height).multipliedBy(1.6/3.0)
            make.top.equalTo(noMainTCStackView.snp.top).inset(10)
            make.trailing.equalTo(noMainTCStackView.snp.trailing)
        }
        
        // 버튼 스택뷰에 버튼 추가
        openedButtonContainerView.addSubview(openedTCButton)
        openedTCButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        upcomingButtonContainerView.addSubview(upcomingTCButton)
        upcomingTCButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 버튼 스택뷰를 뷰에 추가
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            let offset1 = UIScreen.main.bounds.height * (1.1/6.0)
            let offset2 = UIScreen.main.bounds.height * (0.15/6.0)
            make.top.equalTo(mainContainerView.snp.bottom).offset(offset1)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(offset2)// 버튼 높이 조정
        }
    }
    
    // MARK: - Time Capsule Data Fetching
    
    func fetchTimeCapsuleData() {
        DispatchQueue.main.async {
            self.showLoadingIndicator()
        }
        DispatchQueue.global().async {
            let db = Firestore.firestore()
            // 로그인한 사용자의 UID를 가져옵니다.
            //    guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2" // 테스트를 위한 임시 UID
            
            // 사용자의 UID로 필터링하고, openDate 필드로 오름차순 정렬한 후, 최상위 1개 문서만 가져옵니다.
            db.collection("timeCapsules")
                .whereField("uid", isEqualTo: userId)
                .whereField("isOpened", isEqualTo: false) // isOpened가 false인 경우 필터링
                .order(by: "openDate", descending: false) // 가장 먼저 개봉될 타임캡슐부터 정렬
                .limit(to: 1) // 가장 개봉일이 가까운 타임캡슐 1개만 선택
                .getDocuments { [weak self] (querySnapshot, err) in
                    guard let self = self else { return }
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        // 데이터가 없는 경우 처리
                        if querySnapshot?.documents.isEmpty ?? true {
                            print("No upcoming memories found")
                            DispatchQueue.main.async {
                                self.animateMainTCImageChange()
                                self.duestTCInforStackView.removeFromSuperview()
                                self.upcomingTCButton.isEnabled = false
                                self.upcomingTCButton.setBackgroundImage(UIImage(named: "empty"), for: .normal)
                                if let titleLabel = self.upcomingTCButton.subviews.first(where: { $0 is UILabel }) as? UILabel {
                                    titleLabel.text = ""
                                    titleLabel.textColor = .black
                                    titleLabel.backgroundColor = UIColor.gray.withAlphaComponent(0)
                                    titleLabel.font = UIFont.boldSystemFont(ofSize: 100)
                                }
                            }
                        } else if let document = querySnapshot?.documents.first {
                            self.documentId = document.documentID // documentId 업데이트
                            let userLocation = document.get("userLocation") as? String ?? "Unknown Location"
                            let location = document.get("location") as? String ?? "Unknown address"
                            let tcBoxImageURL = document.get("tcBoxImageURL") as? String ?? ""
                            let openDateTimestamp = document.get("openDate") as? Timestamp
                            let openDate = openDateTimestamp?.dateValue()
                            
                            // 메인 스레드에서 UI 업데이트를 수행합니다.
                            DispatchQueue.main.async {
                                self.locationNameLabel.text = userLocation
                                self.locationAddressLabel.text = location
                                self.noMainTCStackView.removeFromSuperview()
                                // D-Day 계산
                                if let openDate = openDate {
                                    let timeCapsule = dDayCalculation(openDate: openDate)
                                    self.dDayLabel.text = timeCapsule.dDay()
                                }
                                
                                if !tcBoxImageURL.isEmpty {
                                    guard let url = URL(string: tcBoxImageURL) else {
                                        print("Invalid photo URL")
                                        return
                                    }
                                    
                                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                                        if let error = error {
                                            print("Error downloading image: \(error)")
                                            return
                                        }
                                        
                                        guard let data = data else {
                                            print("No image data")
                                            return
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.mainTCImageView.image = UIImage(data: data)
                                        }
                                    }.resume()
                                }
                            }
                        }
                    }
                }
            db.collection("timeCapsules")
                .whereField("uid", isEqualTo: userId)
                .whereField("isOpened", isEqualTo: true)
                .getDocuments { [weak self] (querySnapshot, err) in
                    guard let self = self else { return }
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        // 데이터가 없는 경우 처리
                        if querySnapshot?.documents.isEmpty ?? true {
                            print("No saved memories found")
                            DispatchQueue.main.async {
                                self.openedTCButton.isEnabled = false
                                self.openedTCButton.setBackgroundImage(UIImage(named: "empty"), for: .normal)
                                if let titleLabel = self.openedTCButton.subviews.first(where: { $0 is UILabel }) as? UILabel {
                                    titleLabel.text = "NO\nMemories\nYET😭"
                                }
                            }
                        }
                    }
                }
    }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
    }
    
    // MARK: - Image Transition Animation
    
    /// Animates the transition of the main time capsule image.
    func animateMainTCImageChange() {
        // 현재 표시 중인 이미지 페이드 아웃
        UIView.transition(with: mainTCImageView,duration: 3.0, options: .transitionCrossDissolve, animations: {
            self.mainTCImageView.image = self.mainTCImages[self.currentImageIndex]
        },
                          completion: { _ in
            self.moveToNextImage()
            self.animateMainTCImageChange()
        })
    }
    
    /// Moves to the next image in the `mainTCImages` array.
    private func moveToNextImage() {
        currentImageIndex += 1
        if currentImageIndex == mainTCImages.count {
            currentImageIndex = 0
        }
    }
    
    // MARK: - LoadingIndicator
    private func showLoadingIndicator() {
        // SwiftUI 뷰를 UIKit에서 사용할 수 있도록 UIHostingController로 감싸줍니다.
        let hostingController = UIHostingController(rootView: loadingIndicator)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        hostingController.didMove(toParent: self)
        print("showLoadingIndicator가 실행되었습니다")
    }
    
    private func hideLoadingIndicator() {
        // 자식 뷰 컨트롤러들을 순회하면서 UIHostingController를 찾습니다.
        for child in children {
            if let hostingController = child as? UIHostingController<LoadingIndicator> {
                hostingController.willMove(toParent: nil)
                hostingController.view.removeFromSuperview()
                hostingController.removeFromParent()
                print("hideLoadingIndicator가 실행되었습니다")
                break
            }
        }
    }
    // MARK: - VerticalAlignment
    enum VerticalAlignment {
        case top
        case middle
        case bottom
    }

    class VerticallyAlignedLabel: UILabel {
        var verticalAlignment: VerticalAlignment = .middle {
            didSet {
                setNeedsDisplay()
            }
        }

        override func drawText(in rect: CGRect) {
            guard let textString = text else {
                super.drawText(in: rect)
                return
            }

            let attributedText = NSAttributedString(string: textString, attributes: [
                NSAttributedString.Key.font: font as Any,
                NSAttributedString.Key.foregroundColor: textColor as Any
            ])

            var newRect = rect
            let textSize = attributedText.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size

            switch verticalAlignment {
            case .top:
                newRect.size.height = textSize.height
            case .middle:
                newRect.origin.y += (newRect.size.height - textSize.height) / 2
                newRect.size.height = textSize.height
            case .bottom:
                newRect.origin.y += newRect.size.height - textSize.height
                newRect.size.height = textSize.height
            }

            super.drawText(in: newRect)
        }
    }

    // MARK: - Actions
    
    @objc private func addFriendsButtonTapped() {
        print("친구추가가 클릭되었습니다")
        let addFriendsVC = SearchUserTableViewController()
        navigationController?.pushViewController(addFriendsVC, animated: true)
    }
    
    @objc private func duestTCStackViewTapped() {
        print("DuestTC 스택뷰가 클릭되었습니다")
        let mainCapsuleVC = MainCapsuleViewController()
        mainCapsuleVC.documentId = documentId
        navigationController?.pushViewController(mainCapsuleVC, animated: true)
    }
    
    @objc private func addNewTC() {
        print("새 타임머신 만들기 클릭되었습니다")
        let addNewTC = PhotoUploadViewController()
        let navController = UINavigationController(rootViewController: addNewTC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func mainTCImageViewTapped() {
        print("메인 타임캡슐 보러가기 클릭되었습니다")
        let mainCapsuleVC = MainCapsuleViewController()
        mainCapsuleVC.documentId = documentId
        navigationController?.pushViewController(mainCapsuleVC, animated: true)
    }
    
    @objc private func openedTCButtonTapped() {
        print("열어본 타임캡슐 보러가기 클릭되었습니다")
        let openedTCVC = OpenedTCViewController()
        navigationController?.pushViewController(openedTCVC, animated: true)
    }
    
    @objc private func upcomingTCButtonTapped() {
        print("다가오는 타임캡슐 보러가기 클릭되었습니다")
        let upcomingTCVC = UpcomingTCViewController()
        navigationController?.pushViewController(upcomingTCVC, animated: true)
    }
}
//
//import SwiftUI
//struct PreVie11w: PreviewProvider {
//    static var previews: some View {
//        MainTabBarView().toPreview()
//    }
//}
