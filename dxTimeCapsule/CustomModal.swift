//
//  CustomCollection.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/27/24.
//
import UIKit
import SnapKit

class CustomModal: UIViewController{
    private lazy var capsuleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 92/255, green: 177/255, blue: 255/255, alpha: 1.0) // 메인색상
        
        return collectionView
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
            layout.itemSize = CGSize(width: view.frame.width - 48, height: 120)
            layout.minimumLineSpacing = 48 // 최소 줄간격
            //layout.minimumInteritemSpacing = 24
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 500, height: 400) // Placeholder size
    }
}
