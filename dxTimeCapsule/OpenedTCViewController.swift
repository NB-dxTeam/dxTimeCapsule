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

class OpenedTCViewController: UITableViewController {
    
    // MARK: - Properties
    var documentId: String?
    var capsuleInfo = [TCInfo]()
    var onCapsuleSelected: ((Double, Double) -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTimeCapsulesInfo()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        tableView.register(TimeCapsuleCell.self, forCellReuseIdentifier: TimeCapsuleCell.identifier)
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let itemHeight = screenWidth * (11 / 16)
        return itemHeight
    }
    
    // MARK: - Data Fetching
    
    private func fetchTimeCapsulesInfo() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("timeCapsules").whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: true)
            .order(by: "openDate", descending: false)
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    self?.capsuleInfo = documents.compactMap { doc in
                        let data = doc.data()
                        let capsule = TCInfo(
                            id: doc.documentID,
                            tcBoxImageURL: data["photoUrl"] as? String,
                            userLocation: data["userLocation"] as? String,
                            createTimeCapsuleDate: (data["creationDate"] as? Timestamp)?.dateValue() ?? Date(),
                            openTimeCapsuleDate: (data["openDate"] as? Timestamp)?.dateValue() ?? Date()
                        )
                        return capsule
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                } else if let err = err {
                    print("Error getting documents: \(err)")
                }
            }
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capsuleInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCapsuleCell.identifier, for: indexPath) as? TimeCapsuleCell else {
            fatalError("Unable to dequeue TimeCapsuleCell")
        }
        
        let tcInfo = capsuleInfo[indexPath.row]
        cell.configure(with: tcInfo)
        return cell
    }
<<<<<<< HEAD
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let openCapsuleVC = OpenCapsuleViewController()
        let documentId = capsuleInfo[indexPath.row].id
        openCapsuleVC.documentId = documentId
        openCapsuleVC.modalPresentationStyle = .fullScreen
        present(openCapsuleVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completionHandler) in
            // 캡슐 삭제 확인 알림창 띄우기
            self?.showDeleteConfirmationAlert(at: indexPath)
            completionHandler(false) // 완료 핸들러를 호출하지 않고, 알림창을 띄우기 위해 false 반환
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    private func showDeleteConfirmationAlert(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "경고", message: "이 추억은 영원히 기억속으로 사라집니다.\n정말로 이 추억을 삭제하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            // 캡슐 삭제 로직 구현
            self?.deleteCapsule(at: indexPath)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteCapsule(at indexPath: IndexPath) {
        guard let deletedId = capsuleInfo[indexPath.row].id else {
            // 캡슐 정보가 올바르지 않음
            return
        }
      
        // Firestore에서 해당 캡슐 삭제
        let db = Firestore.firestore()
        db.collection("timeCapsules").document(deletedId).delete { [weak self] error in
            if let error = error {
                print("Error deleting capsule: \(error)")
            } else {
                print("Capsule deleted successfully")
                // 데이터 소스에서 삭제된 캡슐 제거 및 UI 업데이트
                self?.capsuleInfo.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
=======
}

//import SwiftUI
//struct PreView5: PreviewProvider {
//    static var previews: some View {
//        OpenedTCViewController().toPreview()
//    }
//}
>>>>>>> origin/dev-yeong3
