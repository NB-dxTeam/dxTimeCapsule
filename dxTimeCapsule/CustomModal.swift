//
//  CustomModal.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/28/24.
//

import NMapsMap
import SnapKit


class CustomModal: UIViewController{
    private lazy var capsuleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBlue
        collection.layer.cornerRadius = 30
        collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collection.layer.masksToBounds = true
        return collection
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configCV()
    }
    
    private func setUpUI() {
        view.addSubview(capsuleCollectionView)
        capsuleCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configCV() {
        capsuleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        capsuleCollectionView.delegate = self
        capsuleCollectionView.dataSource = self
        capsuleCollectionView.register(LockedCapsuleCell.self, forCellWithReuseIdentifier: LockedCapsuleCell.identifier)
        capsuleCollectionView.isPagingEnabled = true
        capsuleCollectionView.showsHorizontalScrollIndicator = false
        capsuleCollectionView.decelerationRate = .fast
        
        if let layout = capsuleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal // 스크롤 방향(가로)
            layout.sectionInset = UIEdgeInsets(top: 48, left: 24, bottom: 24, right: 24)
            layout.itemSize = CGSize(width: view.frame.width - 48, height: 110)
            layout.minimumLineSpacing = 48 // 최소 줄간격
            //layout.minimumInteritemSpacing = 0
            //self.flowLayout = layout
        }
    }
}

extension CustomModal: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 //셀 갯수
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LockedCapsuleCell.identifier, for: indexPath) as? LockedCapsuleCell else {
            fatalError("Unable to dequeue LockedCapsuleCell")
        }
        
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        return CGSize(width: 500, height: 400) // Placeholder size
    //    }
}

//class HalfSizePresentationController: UIPresentationController {
//    override var frameOfPresentedViewInContainerView: CGRect {
//        guard let containerView = containerView else { return CGRect.zero }
//        // 원하는 높이를 정의합니다.
//
//        let originY = containerView.bounds.height / 2// 화면의 1/3 위치에서 모달이 시작되도록 설정
//        return CGRect(x: 0, y: originY, width: containerView.bounds.width, height: containerView.bounds.height * 2 / 3) // 화면의 2/3 만큼의 높이로 모달 크기 설정
//    }
//
//    override func containerViewWillLayoutSubviews() {
//        super.containerViewWillLayoutSubviews()
//        presentedView?.frame = frameOfPresentedViewInContainerView
//    }

