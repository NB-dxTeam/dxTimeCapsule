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
    private var timeBoxes: [TimeBox] = []
    var onCapsuleSelected: ((Double, Double) -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTimeBoxesInfo()
        // 네비게이션 바 스타일 설정
        setupNavigationBarAppearance()
        // 왼쪽 backButton 설정
        setupBackButton()
        // 타이틀 설정
        navigationItem.title = "Saved memories"
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
    
    // 네비게이션 바 스타일 설정 메서드
    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage(named: "gray_line")
    }
    
    // 왼쪽 backButton 설정 메서드
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")
        backButton.setBackgroundImage(image, for: .normal)
        backButton.tintColor = UIColor(red: 209/255.0, green: 94/255.0, blue: 107/255.0, alpha: 1)
        backButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        
        // backButton 위치 설정
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        // 네비게이션 아이템에 backButton 설정
        let backButtonBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonBarItem
    }

    // MARK: - Data Fetching
    
    private func fetchTimeBoxesInfo() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("timeCapsules")
            .whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: true)
            .order(by: "openTimeBoxDate", descending: false)
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    print("documents 개수: \(documents.count)")
                    self?.timeBoxes = documents.compactMap { doc in
                        let data = doc.data()
                        let timeBox = TimeBox(
                            id: doc.documentID,
                            imageURL: (data["imageURL"] as? [String]),
                            addressTitle: data["addressTitle"] as? String,
                            createTimeBoxDate: data["createTimeBoxDate"] as? Timestamp,
                            openTimeBoxDate: data["openTimeBoxDate"] as? Timestamp
                        )
                        print("매핑된 타임박스: \(timeBox)")
                        return timeBox
                    }
                    print("Fetching time boxes for userID: \(userId)")
                    print("Fetched \(self?.timeBoxes.count ?? 0) time boxes")
                    
                    DispatchQueue.main.async {
                        print("tableView reload.")
                        self?.tableView.reloadData()
                    }
                } else if let err = err {
                    print("Error getting documents: \(err)")
                }
            }
    }
    
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeBoxes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCapsuleCell.identifier, for: indexPath) as? TimeCapsuleCell else {
            fatalError("Unable to dequeue TimeCapsuleCell")
        }
        
        let timeBox = timeBoxes[indexPath.row]
        cell.configure(with: timeBox)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let openCapsuleVC = OpenCapsuleViewController()
        let documentId = timeBoxes[indexPath.row].id
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
        guard let deletedId = timeBoxes[indexPath.row].id else {
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
                self?.timeBoxes.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

// MARK: - Actions
    
@objc private func homeButtonTapped() {
       let tabBarController = MainTabBarView()
       tabBarController.modalPresentationStyle = .fullScreen
       present(tabBarController, animated: true, completion: nil)
   }
}
