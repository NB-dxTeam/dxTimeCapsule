//
//  OpenedTCViewController.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 3/8/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

//#Preview{
//    OpenedTCViewController()
//}

class OpenedTCViewController: UIViewController {
    
    // MARK: - Properties
    
    var capsuleInfo = [TCInfo]()
    var onCapsuleSelected: ((Double, Double) -> Void)?
    private var capsuleCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.layer.cornerRadius = 30
        collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collection.layer.masksToBounds = true
        return collection
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configCollection()
        fetchTimeCapsulesInfo()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(capsuleCollection)
        capsuleCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configCollection() {
        capsuleCollection.delegate = self
        capsuleCollection.dataSource = self
        capsuleCollection.register(TimeCapsuleCell.self, forCellWithReuseIdentifier: TimeCapsuleCell.identifier)
        capsuleCollection.isPagingEnabled = true
        capsuleCollection.showsVerticalScrollIndicator = true
        capsuleCollection.decelerationRate = .normal
        capsuleCollection.alpha = 1
        
        if let layout = capsuleCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = screenWidth * 0.9
            let itemHeight: CGFloat = 250
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            let sectionInsetHorizontal = screenWidth * 0.05
            layout.sectionInset = UIEdgeInsets(top: 24, left: sectionInsetHorizontal, bottom: 24, right: sectionInsetHorizontal)
            let minimumLineSpacing = screenWidth * 0.1
            layout.minimumLineSpacing = minimumLineSpacing
        }
    }
    
    // MARK: - Data Fetching
    
    private func fetchTimeCapsulesInfo() {
        let db = Firestore.firestore()
        let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2"
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: true)
            .order(by: "openDate", descending: false)
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    print("documents 개수: \(documents.count)")
                    self?.capsuleInfo = documents.compactMap { doc in
                        let data = doc.data()
                        let capsule = TCInfo(
                            tcBoxImageURL: data["photoUrl"] as? String,
                            userLocation: data["userLocation"] as? String,
                            createTimeCapsuleDate: (data["creationDate"] as? Timestamp)?.dateValue() ?? Date(),
                            openTimeCapsuleDate: (data["openDate"] as? Timestamp)?.dateValue() ?? Date()
                        )
                        print("매핑된 캡슐: \(capsule)")
                        return capsule
                    }
                    print("Fetching time capsules for userID: \(userId)")
                    print("Fetched \(self?.capsuleInfo.count ?? 0) timecapsules")
                    
                    DispatchQueue.main.async {
                        print("collectionView reload.")
                        self?.capsuleCollection.reloadData()
                    }
                } else if let err = err {
                    print("Error getting documents: \(err)")
                }
            }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension OpenedTCViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capsuleInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeCapsuleCell.identifier, for: indexPath) as? TimeCapsuleCell else {
            fatalError("Unable to dequeue OpendedTCCell")
        }
        
        let tcInfo = capsuleInfo[indexPath.row]
        cell.configure(with: tcInfo)
        return cell
    }
}

//import SwiftUI
//struct PreVie10w: PreviewProvider {
//    static var previews: some View {
//        OpenedTCViewController().toPreview()
//    }
//}
