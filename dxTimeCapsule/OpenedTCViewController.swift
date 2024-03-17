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

class OpenedTCViewController: UIViewController {
    
    // MARK: - Properties
    var documentId: String?
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
            let itemHeight = screenWidth * (10.5/16)
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            let minimumLineSpacing = screenWidth * 0.05
            layout.minimumLineSpacing = minimumLineSpacing
        }
    }
    
    // MARK: - Data Fetching
    
    private func fetchTimeCapsulesInfo() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
//              let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2" 
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: true)
            .order(by: "openDate", descending: false)
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    print("documents 개수: \(documents.count)")
                    self?.capsuleInfo = documents.compactMap { doc in
                        let data = doc.data()
                        let capsule = TCInfo(
                            id: doc.documentID,
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let openCapsuleVC = OpenCapsuleViewController()
        // 선택된 캡슐의 문서 ID를 가져와서 전달
        let documentId = capsuleInfo[indexPath.item].id
        openCapsuleVC.documentId = documentId
        openCapsuleVC.modalPresentationStyle = .fullScreen
        present(openCapsuleVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let deleteAction = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                // 삭제 액션 처리
                let deletedDocumentId = self.capsuleInfo[indexPath.item].id
                if let documentId = deletedDocumentId {
                    self.showDeleteConfirmationAlert(for: documentId, at: indexPath)
                }
            }
            
            return UIMenu(title: "", children: [deleteAction])
        }
        
        return configuration
    }
    
    private func showDeleteConfirmationAlert(for documentId: String, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "삭제 확인", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteDocumentFromFirebase(documentId: documentId, at: indexPath)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteDocumentFromFirebase(documentId: String, at indexPath: IndexPath) {
        let db = Firestore.firestore()
        db.collection("timeCapsules").document(documentId).delete { [weak self] error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                // Firebase에서 문서를 삭제한 후에는 로컬 데이터를 업데이트하고 UI를 업데이트해야 합니다.
                self?.capsuleInfo.remove(at: indexPath.item)
                self?.capsuleCollection.deleteItems(at: [indexPath])
            }
        }
    }
}
