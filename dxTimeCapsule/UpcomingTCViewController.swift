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
    
    private var timeBoxes: [TimeBox] = []
    var onCapsuleSelected: ((Double, Double) -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTimeBoxesInfo()
        backButtonNavigationBar()
//        // 네비게이션 바 스타일 설정
//        setupNavigationBarAppearance()
//        // 왼쪽 backButton 설정
//        setupBackButton()
//        // 타이틀 설정
//        navigationItem.title = "Upcoming memories"
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
    
//    // 네비게이션 바 스타일 설정 메서드
//    private func setupNavigationBarAppearance() {
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.shadowImage = UIImage(named: "gray_line")
//    }
    
//    // 왼쪽 backButton 설정 메서드
//    private func setupBackButton() {
//        let backButton = UIButton(type: .system)
//        let image = UIImage(systemName: "chevron.left")
//        backButton.setBackgroundImage(image, for: .normal)
//        backButton.tintColor = UIColor(red: 209/255.0, green: 94/255.0, blue: 107/255.0, alpha: 1)
//        backButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
//        backButton.frame = CGRect(x: 0, y: 0, width: 15, height: 30)
//        
//        // backButton 위치 설정
////        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
//        
//        // 네비게이션 아이템에 backButton 설정
//        let backButtonBarItem = UIBarButtonItem(customView: backButton)
//        navigationItem.leftBarButtonItem = backButtonBarItem
//    }
    
    // MARK: - Data Fetching
    
    private func fetchTimeBoxesInfo() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("timeCapsules")
            .whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: false)
            .order(by: "openTimeBoxDate", descending: false)
            .getDocuments { [weak self] (querySnapshot, err) in
                if let documents = querySnapshot?.documents {
                    print("documents 개수: \(documents.count)")
                    self?.timeBoxes = documents.compactMap { doc in
                        let data = doc.data()
                        let timeBox = TimeBox(
                            id: doc.documentID,
                            thumbnailURL: data["thumbnailURL"] as? String,
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
        cell.configure(with: timeBox, dDayColor: UIColor(.red), controllerType: .UpcomingTCViewControllerLogic)
        return cell
    }
    
    // MARK: - Actions
        
    @objc private func homeButtonTapped() {
           let tabBarController = MainTabBarView()
           tabBarController.modalPresentationStyle = .fullScreen
           present(tabBarController, animated: true, completion: nil)
       }
    }


//import SwiftUI
//struct PreVie11w: PreviewProvider {
//    static var previews: some View {
//        MainTabBarView().toPreview()
//    }
//}

extension UpcomingTCViewController {
    func backButtonNavigationBar() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.hidesBackButton = true
        
        // 타이틀 설정
        navigationItem.title = "Upcoming memories"
        
        // 백 버튼 생성
        let backButton = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")
        backButton.setBackgroundImage(image, for: .normal)
        backButton.tintColor = UIColor(red: 209/255.0, green: 94/255.0, blue: 107/255.0, alpha: 1)
        backButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)

        
        // 내비게이션 바에 백 버튼 추가
         navigationController?.navigationBar.addSubview(backButton)
        
        // 백 버튼의 위치 조정
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.centerYAnchor.constraint(equalTo: navigationController!.navigationBar.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: navigationController!.navigationBar.leadingAnchor, constant: 20).isActive = true
    }
}
