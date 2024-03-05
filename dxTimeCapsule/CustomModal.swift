//
//  CustomModal.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/28/24.
//

import NMapsMap
import SnapKit


class CustomModal: UIViewController{
    
    var timeCapsule = [TimeCapsule]()
    let dummyTimeCapsules = [
        TimeCapsule(timeCapsuleId: "1", uid: "user123", mood: "Happy", photoUrl: "a-1", location: "#제주  #제주도 #김녕해수욕장", userLocation: "Namsan Tower", comment: "Great day!", tags: ["tag1", "tag2"], openDate: Date(), creationDate: Date()),
        TimeCapsule(timeCapsuleId: "2", uid: "user124", mood: "Happy", photoUrl: "a-2", location: "#부산  #해운대 #바다", userLocation: "Namsan Tower", comment: "Great day!", tags: ["tag3", "tag4"], openDate: Date(), creationDate: Date()),
        TimeCapsule(timeCapsuleId: "3", uid: "user125", mood: "Happy", photoUrl: "a-3", location: "#익산  #아가페정원 #메타세쿼이아", userLocation: "Namsan Tower", comment: "Great day!", tags: ["tag5", "tag6"], openDate: Date(), creationDate: Date()),
        TimeCapsule(timeCapsuleId: "4", uid: "user126", mood: "Happy", photoUrl: "a-4", location: "#대천  #대천해수욕장 #여름휴가지", userLocation: "Namsan Tower", comment: "Great day!", tags: ["tag7", "tag8"], openDate: Date(), creationDate: Date()),
    ]
    private var capsuleCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.layer.cornerRadius = 30
        collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collection.layer.masksToBounds = true
        return collection
    }()
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configCV()
    }
    // addsubView, autolayout
    private func setupUI() {
        view.addSubview(capsuleCollection)
        capsuleCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configCV() {
        capsuleCollection.translatesAutoresizingMaskIntoConstraints = false
        capsuleCollection.delegate = self
        capsuleCollection.dataSource = self
        capsuleCollection.register(LockedCapsuleCell.self, forCellWithReuseIdentifier: LockedCapsuleCell.identifier)
        capsuleCollection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        capsuleCollection.isPagingEnabled = true
        capsuleCollection.showsHorizontalScrollIndicator = true
        capsuleCollection.decelerationRate = .fast
        capsuleCollection.alpha = 0.8
        if let layout = capsuleCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical // 스크롤 방향(가로)
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = screenWidth * 0.9 // 화면 너비의 90%를 아이템 너비로 설정
            let itemHeight: CGFloat = 250 // 아이템 높이는 고정 값으로 설정
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            
            let sectionInsetHorizontal = screenWidth * 0.05 // 좌우 여백을 화면 너비의 5%로 설정
            layout.sectionInset = UIEdgeInsets(top: 24, left: sectionInsetHorizontal, bottom: 24, right: sectionInsetHorizontal)
            let minimumLineSpacing = screenWidth * 0.1 // 최소 줄 간격을 화면 너비의 10%로 설정
            layout.minimumLineSpacing = minimumLineSpacing
            
        }
    }
    
}

extension CustomModal: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyTimeCapsules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LockedCapsuleCell.identifier, for: indexPath) as? LockedCapsuleCell else {
            fatalError("Unable to dequeue LockedCapsuleCell")
        }
        
        let timeCapsule = dummyTimeCapsules[indexPath.item]
        cell.registerImage.image = UIImage(named: timeCapsule.photoUrl ?? "placeholder")
        cell.dayBadge.text = "D-\(daysUntilOpenDate(timeCapsule.openDate))"
        cell.registerPlace.text = timeCapsule.location ?? ""
        cell.registerDay.text = dateFormatter.string(from: timeCapsule.creationDate)
        print("위치: \(timeCapsule.location ?? ""), 개봉일: \(timeCapsule.openDate), 등록일: \(timeCapsule.creationDate), 사용자 위치: \(timeCapsule.userLocation ?? "") ")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        //headerView.sortButtonAction = { [weak self] in
        // 등록일순, D-day순, 거리순 로직 구현
        //}
        
        //collectionView.reloadData()
        headerView.headerLabel.text = "여기에 정렬 옵션 추가"
        return headerView
    }
}

extension CustomModal: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // 헤더 뷰의 크기 설정
        return CGSize(width: collectionView.frame.width, height: 48)
    }
}

extension CustomModal {
    // D-Day 남은 일수 계산
    func daysUntilOpenDate(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
}

// MARK: - CollectionView Header
class HeaderView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderView"
    
    // 정렬 버튼
//    private let sortCapsule: UIButton = {
//        let button = UIButton()
//        button.setTitle("등록일순", for: .normal)
//        return button
//    }()
    var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "여기에 정렬 옵션 추가"
        return label
    }()
    
    // 버튼 클로저
    var sortButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.top.equalTo(20)
            
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func didTapSortButton() {
//        sortButtonAction?()
//    }
}

// MARK: Custom Sheet Size
extension UISheetPresentationController.Detent {
    static var small: UISheetPresentationController.Detent {
        Self.custom { context in
            return context.maximumDetentValue * 0.25
        }
    }
}
