//
//  UpcomingTCViewController.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 3/8/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class UpcomingTCViewController: UITableViewController {
    
    // MARK: - Properties
    
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
            .whereField("isOpened", isEqualTo: false)
            .order(by: "openDate", descending: false)
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    print("documents 개수: \(documents.count)")
                    self?.capsuleInfo = documents.compactMap { doc in
                        let data = doc.data()
                        let capsule = TCInfo(
                            id: doc.documentID,
                            tcBoxImageURL: data["tcBoxImageURL"] as? String,
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
}
