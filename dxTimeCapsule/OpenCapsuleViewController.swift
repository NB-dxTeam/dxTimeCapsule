//
//  OpenCapsuleViewController.swift
//  dxTimeCapsule
//
//  Created by 김우경 on 3/7/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseFirestore
//import SDWebImage

class OpenCapsuleViewController: UIViewController, UIScrollViewDelegate {
    var documentId: String?
    var creationDate: Date? // 타임캡슐이 생성된 날짜
    var openDate: Date? // 타임캡슐이 열린 날짜
    var userMessage: String? // 사용자 메시지
    var taggedFriendName: [String] = []
    var indexOfTaggedImage: Int = 0 // 태그가 있는 이미지의 인덱스를 설정하세요.
    
    private var topBarView: UIView!
    private var homeButton: UIButton!
    private var titleLabel: UILabel!
    private var separatorLine: UIView!
    private var locationLabel: UILabel!
    private var detailedAddressLabel: UILabel!
    
    private var capsuleImageView: UIImageView!
    private var imageScrollView: UIScrollView!
    private var currentPage = 0 // 현재 페이지 인덱스를 추적
    private var pageControl: CustomPageControl!
    
    private var tagIconImageView: UIImageView!
    
    private var memoryTextView: UITextView!
    private var messageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUIComponents()
        setupHomeButton()
        loadTimeCapsuleData()
        setupPageControl()
        addTagIcon() // 태그 아이콘 추가
        setupTagTapRecognizer() // 탭 제스처 인식기 설정
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageButton.setInstagram()
    }
    
    private func setupImageScrollView(with imagesCount: Int) {
        let scrollViewWidth = self.view.frame.width
        let scrollViewHeight = imageScrollView.frame.height
        imageScrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(imagesCount), height: scrollViewHeight)
    }
  
    private func setupPageControl() {
        pageControl = CustomPageControl()
        pageControl.numberOfPages = 0 // 페이지 수는 나중에 업데이트합니다.
        pageControl.currentPage = 0
        pageControl.enlargedIndex = -1 // 기본적으로 마지막 인디케이터는 크지 않도록 설정합니다.
        pageControl.currentPageIndicatorTintColor = .systemBlue // 현재 페이지 인디케이터 색상 설정
           pageControl.pageIndicatorTintColor = .lightGray // 나머지 페이지 인디케이터 색상 설정

        // 다른 설정도 추가할 수 있습니다.
        view.addSubview(pageControl)
         pageControl.snp.makeConstraints { make in
             make.centerX.equalToSuperview()
             make.top.equalTo(imageScrollView.snp.bottom).offset(8) // 이미지 밑에
             make.width.equalTo(160) // 화면 폭을 설정해서 인디케이터의 길이을 조절
             }
     }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 이미지 스크롤뷰의 현재 페이지 인덱스 계산
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
        
        // 마지막 인디케이터가 더 크게 설정되어야 하는 경우에만 enlargedIndex 값을 변경
        if pageControl.currentPage < pageControl.numberOfPages - 1 {
            pageControl.enlargedIndex = pageControl.numberOfPages - 1
        } else {
            pageControl.enlargedIndex = -1
        }
        // 현재 페이지에 따라 태그 아이콘 표시 여부 결정
        updateTagIconVisibility(currentPage: currentPage)
    }
    
    // 현재 보이는 페이지에 따라 태그 아이콘의 가시성을 업데이트하는 메서드입니다.
    private func updateTagIconVisibility(currentPage: Int) {
        // 태그가 있는 페이지 인덱스와 현재 페이지가 같으면 태그 아이콘을 보여줍니다.
        if currentPage == indexOfTaggedImage {
            // tagIconImageView의 위치를 현재 페이지의 이미지와 관련된 위치로 업데이트
            view.bringSubviewToFront(tagIconImageView)
            tagIconImageView.isHidden = false
        } else {
            tagIconImageView.isHidden = true
        }
    }
    
    private func addTagIcon() {
        if let customIconImage = UIImage(named: "myCustomTagIcon") {
                tagIconImageView = UIImageView(image: customIconImage)
            } else {
                // 에셋을 찾을 수 없는 경우, 시스템 아이콘을 대신 사용합니다.
                tagIconImageView = UIImageView(image: UIImage(systemName: "tag"))
                tagIconImageView.tintColor = .white
            }
        tagIconImageView.isUserInteractionEnabled = true
        

        // tagIconImageView를 self.view의 하위 뷰로 추가합니다.
        self.view.addSubview(tagIconImageView)

        // 이제 tagIconImageView의 위치를 새로운 상위 뷰에 맞게 조정합니다.
        tagIconImageView.snp.makeConstraints { make in
            // 위치 조정이 필요합니다. 예를 들어, 이미지 뷰와 같은 위치에 놓고 싶다면:
            make.bottom.equalTo(self.imageScrollView.snp.bottom).offset(-16)
            make.right.equalTo(self.view.snp.right).offset(-16)
            make.width.height.equalTo(24)
        }

        // zPosition을 조정하여 tagIconImageView를 가장 앞으로 가져옵니다.
        tagIconImageView.layer.zPosition = 1
    }
    
    // 탭 제스처 인식기를 추가하고 태그된 사용자의 이름을 표시하는 메소드
    private func setupTagTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tagIconTapped))
        tagIconImageView.addGestureRecognizer(tapRecognizer)
    }

    @objc private func tagIconTapped() {
        // 각각의 이름에 대한 레이블을 생성하고 화면에 표시합니다.
        for (index, name) in taggedFriendName.enumerated() {
            showTaggedFriendName(name, atIndex: index)
        }
    }

    private func showTaggedFriendName(_ name: String, atIndex index: Int) {
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.backgroundColor = .black.withAlphaComponent(0.5)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.layer.cornerRadius = 5
        nameLabel.clipsToBounds = true
        nameLabel.numberOfLines = 0
        
        nameLabel.sizeToFit()
        nameLabel.frame.size = CGSize(width: min(nameLabel.frame.width, self.view.frame.width - 40), height: nameLabel.frame.height + 10)
        
        let tagIconFrameInSuperview = tagIconImageView.superview?.convert(tagIconImageView.frame, to: self.view) ?? CGRect.zero
        
        nameLabel.center.x = tagIconFrameInSuperview.midX
        nameLabel.center.y = tagIconFrameInSuperview.minY - CGFloat(index + 1) * (nameLabel.frame.height + 5)
        
        // 이름 레이블이 화면 왼쪽을 벗어나지 않도록 조정
        nameLabel.frame.origin.x = max(nameLabel.frame.origin.x, 20)
        
        // 이름 레이블이 화면 오른쪽을 벗어나지 않도록 조정
        if nameLabel.frame.maxX > self.view.frame.width - 20 {
            nameLabel.frame.origin.x = self.view.frame.width - nameLabel.frame.width - 20
        }
        
        self.view.addSubview(nameLabel)
        
        // 레이블을 일정 시간 후에 사라지게 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            nameLabel.removeFromSuperview()
        }
    }
    
        private func setupHomeButton() {
        homeButton = UIButton(type: .system)
        let homeImage = UIImage(systemName: "chevron.left") // SF Symbols에서 "house.fill" 이미지 사용
        homeButton.setImage(homeImage, for: .normal)
        homeButton.tintColor = UIColor(hex: "#C82D6B") // 버튼 색상 설정
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        
        topBarView.addSubview(homeButton) // topBarView에 버튼 추가
        homeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview() // 상단바 뷰의 센터와 맞춤
            make.width.height.equalTo(30) // 버튼의 크기 설정
        }
    }
    
    @objc private func homeButtonTapped() {
           let tabBarController = MainTabBarView()
           tabBarController.modalPresentationStyle = .fullScreen
           present(tabBarController, animated: true, completion: nil)
       }
    
    private func setupUIComponents() {
        // 상단 바 뷰 설정
        topBarView = UIView()
        //        topBarView.backgroundColor = .systemBlue // 상단 바의 배경색 설정
        view.addSubview(topBarView)
        topBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44) // 상단 바의 높이 설정
        }
        
        // 상단 바 타이틀 레이블 설정
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0 // 여러 줄의 텍스트를 표시
        titleLabel.textAlignment = .center // 가운데 정렬
        
        // titleLabel을 topBarView에 추가하고 제약 조건을 설정
        topBarView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        // 구분선 뷰 설정
        separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.lightGray
        topBarView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6) // 타이틀 레이블 아래
            make.leading.trailing.equalToSuperview() // 상단 바의 양쪽 가장자리에 맞춤
            make.height.equalTo(0.2) // 높이를 0.5로 설정하여 실선처럼 보이게 함
        }
        
        // 위치 레이블 초기화 및 설정
        locationLabel = UILabel()
        locationLabel.text = "Loading.."
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.textAlignment = .center
        view.addSubview(locationLabel)
        locationLabel.textAlignment = .left
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
        }
        
        // 세부 주소 레이블 초기화 및 설정
        detailedAddressLabel = UILabel()
        detailedAddressLabel.text = "Loading.."
        detailedAddressLabel.font = UIFont.systemFont(ofSize: 10)
        detailedAddressLabel.textColor = .gray
        detailedAddressLabel.textAlignment = .center
        view.addSubview(detailedAddressLabel)
        detailedAddressLabel.textAlignment = .left
        detailedAddressLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationLabel.snp.leading) // 위치 레이블과 동일한 leading
            make.top.equalTo(locationLabel.snp.bottom).offset(0.5)
        }
        
        // 이미지 뷰 설정
        capsuleImageView = UIImageView()
        capsuleImageView.contentMode = .scaleAspectFill // 이미지가 뷰를 꽉 채우도록 설정
        capsuleImageView.clipsToBounds = true // 이미지가 뷰 밖으로 나가지 않도록
        capsuleImageView.backgroundColor = .systemGray4 // 사용하지 않는 영역을 회색으로 표시
        
        view.addSubview(capsuleImageView)
        
        capsuleImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(detailedAddressLabel.snp.bottom).offset(7)
            // 비율 제약 조건 (가로 대비 세로를 4:5로 설정) 인스타사이즈
            make.height.equalTo(capsuleImageView.snp.width).multipliedBy(5.0/4.0)
        }
        
        // 이미지 스크롤 뷰 설정
        imageScrollView = UIScrollView()
        imageScrollView.delegate = self
        imageScrollView.isPagingEnabled = true
        imageScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(imageScrollView)
        imageScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(detailedAddressLabel.snp.bottom).offset(7)
            make.height.equalTo(imageScrollView.snp.width).multipliedBy(5.0/4.0) // 비율 유지
        }
        
        // 메모리 텍스트 뷰 설정
        memoryTextView = UITextView()
        memoryTextView.text =  """
                                지난 2022년 10월 6일은
                                지민님과 함께 보내셨군요!
                                굉장히 즐거웠던 날이에요.😋
                                """
        memoryTextView.isEditable = false
        memoryTextView.isScrollEnabled = false
        memoryTextView.font = UIFont.systemFont(ofSize: 14) // 폰트 설정
        memoryTextView.textAlignment = .center
        view.addSubview(memoryTextView)
        memoryTextView.snp.makeConstraints { make in
            // 여기 레이아웃 다시 설정해야함 임시임
            make.top.equalTo(imageScrollView.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 메시지 확인하기 버튼 설정
        messageButton = UIButton(type: .system)
        messageButton.setTitle("그날의 메시지", for: .normal)
        messageButton.setInstagram() // 색상 설정
        messageButton.setTitleColor(.white, for: .normal)
        messageButton.layer.cornerRadius = 10
        view.addSubview(messageButton)
        messageButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
        
        // messageButton 이벤트 추가 (예시로 로그 출력)
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
    }
    
    //그날의 메시지 탭
    @objc private func messageButtonTapped() {
        let messageModalVC = MessageModalViewController()
        
        // Firestore에서 가져온 Date 타입의 날짜 데이터를 사용하도록 설정합니다.
        messageModalVC.creationDate = self.creationDate // 가정: self.creationDate는 Date 타입
        messageModalVC.openDate = self.openDate // 가정: self.openDate는 Date 타입
        // descriptionText 대신 userMessage를 사용합니다.
        messageModalVC.userMessage = self.userMessage // 가정: self.userMessage는 String 타입
        // 모달 프레젠테이션 스타일 설정
        messageModalVC.modalPresentationStyle = .pageSheet // 또는 .formSheet
        
        // iOS 15 이상에서의 추가 설정
        if let presentationController = messageModalVC.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()] // 원하는 높이 설정
            // 더 많은 설정을 할 수 있습니다.
        }

        // 모달 표시
        self.present(messageModalVC, animated: true, completion: nil)
    }
    
    private func loadTimeCapsuleData() {
        guard let documentId = documentId else { return }
        
        let db = Firestore.firestore()
        db.collection("timeCapsules").document(documentId).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                
                return
                
            }
            
            // DateFormatter 설정
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            dateFormatter.locale = Locale(identifier: "ko_KR")
            
            // 'creationDate' 필드 값
            let creationDateTimestamp = document.get("createTimeBoxDate") as? Timestamp
            self.creationDate = creationDateTimestamp?.dateValue()
            let creationDateString = self.creationDate.map { dateFormatter.string(from: $0) } ?? "날짜 정보 없음"
            
            // 'openDate' 필드 값
            let openDateTimestamp = document.get("openTimeBoxDate") as? Timestamp
            self.openDate = openDateTimestamp?.dateValue()
            let openDateString = self.openDate.map { dateFormatter.string(from: $0) } ?? "날짜 정보 없음"
            
            // 'description' 필드 값
            self.userMessage = document.get("description") as? String
            
            // 'username' 필드 값
            let userName = document.get("userName") as? String ?? "사용자"
            
            // 'userLocation' 필드 값
            let userLocation = document.get("addressTitle") as? String ?? "위치 정보 없음"
            
            // 'location' 필드 값
            let detailedLocation = document.get("address") as? String ?? "세부 주소 정보 없음"
            
            // 'mood' 필드 값
            //                 let mood = document.get("mood") as? String ?? ""
            
            
            // Firestore에서 이미지 URL 배열 로딩 후 이미지 뷰 생성 및 추가
            if let imageUrlStrings = document.get("imageURL") as? [String], !imageUrlStrings.isEmpty {
                let totalImages = imageUrlStrings.count
                
                // PageControl 설정
                pageControl.numberOfPages = totalImages
                pageControl.currentPage = 0
                pageControl.enlargedIndex = totalImages > 5 ? 4 : totalImages - 1 // 5개를 초과하는 경우, '...'을 표시
                
                for (index, urlString) in imageUrlStrings.enumerated() {
                    if let url = URL(string: urlString) {
                        let imageView = UIImageView()
                        imageView.contentMode = .scaleAspectFill
                        imageView.clipsToBounds = true
                        // 여기에 이미지 로딩 코드 추가 (예: URLSession, SDWebImage, AlamofireImage 등)
                        imageView.loadImage(from: url) // 예시 함수, 실제 이미지 로딩 로직 필요
                        
                        let xPosition = self.imageScrollView.frame.width * CGFloat(index)
                        imageView.frame = CGRect(x: xPosition, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
                        
                        self.imageScrollView.addSubview(imageView)
                        
                        // loadTimeCapsuleData() 메소드 내의 이미지 로딩 로직 후에 추가
                        setupImageScrollView(with: imageUrlStrings.count)
                    }
                }
            }
            
            // 'friendID' 필드 값 처리
            // 여기서 self.taggedFriendName에 값을 할당합니다.
            let friendID = document.get("tagFriendName") as? [String] ?? []
            self.taggedFriendName = friendID // 이 부분이 수정되었습니다.
            
            // UI 업데이트는 메인 스레드에서 해야 합니다.
            DispatchQueue.main.async {
                // 'friendID'에 따른 문자열 설정
                let friendSentence: String
                if friendID.isEmpty {
                    friendSentence = "\(userLocation)에서 보내셨군요"
                } else if friendID.count == 1 {
                    friendSentence = "\(friendID.first!)님과 함께 보내셨군요!"
                } else {
                    friendSentence = "많은 분들과 함께 하셨군요!"
                }
                
                
                // 메모리 텍스트뷰에 표시할 문자열을 설정
                DispatchQueue.main.async {
                    self.updateTitleLabel(with: userName)
                    self.locationLabel.text = userLocation
                    self.detailedAddressLabel.text = detailedLocation
                    self.memoryTextView.text = """
                \(userName)님의 지난 \(creationDateString)은
                \(friendSentence)
                어떤 추억을 남겼는지 확인해보세요😋
                """
                    
                    // Firestore에서 tagFriendName 데이터를 불러오고 나서 태그 아이콘을 추가
                    if !self.taggedFriendName.isEmpty {
                        // indexOfTaggedImage는 실제 태그된 이미지의 인덱스로 업데이트해야 합니다.
                        self.indexOfTaggedImage = 0 // 이 부분을 올바른 인덱스로 설정해야 합니다.
                        self.addTagIcon() // 태그 아이콘 추가
                        self.setupTagTapRecognizer() // 태그 제스처 인식기 설정
                    }
                }
            }
        }
    }
    private func updateTitleLabel(with userId: String) {
        let userIdTextAttributes: [NSAttributedString.Key: Any] = [
              .font: UIFont.systemFont(ofSize: 12),
              .foregroundColor: UIColor.darkGray
          ]
          
          let timeCapsuleTextAttributes: [NSAttributedString.Key: Any] = [
              .font: UIFont.boldSystemFont(ofSize: 14),
              .foregroundColor: UIColor.black
          ]
          
          let userIdString = NSAttributedString(string: "\(userId)\n", attributes: userIdTextAttributes)
          let timeCapsuleString = NSAttributedString(string: "Time Box", attributes: timeCapsuleTextAttributes)
          
          let combinedAttributedString = NSMutableAttributedString()
          combinedAttributedString.append(userIdString)
          combinedAttributedString.append(timeCapsuleString)
          
          // 'titleLabel'의 'attributedText'를 업데이트합니다.
          titleLabel.attributedText = combinedAttributedString
      }
}

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}
