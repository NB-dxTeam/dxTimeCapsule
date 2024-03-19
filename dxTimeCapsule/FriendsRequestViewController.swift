//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//

import UIKit
class FriendsRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - 여기 지우기 03/19 황주영
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
//    
//    
//    private var db = Firestore.firestore()
//    
////    private var alarmLabel: UILabel!
//    private var friendRequests: [User] = []
//    private var timeBox: [TimeBox] = []
//    private let tableView = UITableView()
//    private let viewModel = FriendsViewModel()
//    
//    private let noRequestsLabel: UILabel = {
//        let label = UILabel()
//        label.text = "친구 요청이 없습니다"
//        label.textAlignment = .center
//        label.textColor = .gray
//        label.isHidden = false
//        return label
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setUI()
//        setupTableView()
//        fetchFriendRequests()
//        observeFriendRequests()
//    }
//    
//    func setUI() {
////        alarmLabel = UILabel()
////        alarmLabel.text = "알람"
////        alarmLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
////        alarmLabel.textAlignment = .left
////
////        view.addSubview(alarmLabel)
////
////        alarmLabel.snp.makeConstraints { make in
////            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-40)
////            make.leading.trailing.equalToSuperview().offset(16)
////        }
//        
//        view.addSubview(noRequestsLabel)
//        noRequestsLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
//        noRequestsLabel.center = view.center
//        
//        noRequestsLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview() // 중앙에 표시되도록
//        }
//    }
//    
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "FriendRequestCell")
//        tableView.register(CapsuleTableViewCell.self, forCellReuseIdentifier: "CapsuleCell")
//        tableView.tableFooterView = UIView()
//        
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//            make.leading.bottom.trailing.equalToSuperview()
//        }
//    }
//    
//    private func fetchFriendRequests() {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        viewModel.fetchFriendRequests(forUser: currentUserId) { [weak self] users, error in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if let users = users {
//                    self.friendRequests = users
//                    self.updateUI()
//                    self.tableView.reloadData()
//                    print("fetchDataSuccess")
//                } else if let error = error {
//                    print("Error fetching friend requests: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    private func fetchCapsules() {
//        guard let userID = Auth.auth().currentUser?.uid else { return }
//        db.collection("TimeCapsules").whereField("uid", isEqualTo: userID).order(by: "openTimeCapsuleDate", descending: false).getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                var timeBox: [TimeBox] = []
//                snapshot?.documents.forEach { document in
//                    let data = document.data()
//                    let id = document.documentID
//                    let uid = data["uid"] as? String ?? ""
//                    let userName = data["userName"] as? String ?? ""
//                    let imageURL = data["imageURL"] as? [String] ?? []
//                    let description = data["description"] as? String ?? ""
//                    let tagFriendName = data["tagFriends"] as? [String] ?? []
//                    let createTimeCapsuleDate = (data["createTimeCapsuleDate"] as? Timestamp)?.dateValue() ?? Date()
//                    let openTimeCapsuleDate = (data["openTimeCapsuleDate"] as? Timestamp)?.dateValue() ?? Date()
//                    let isOpened = data["isOpened"] as? Bool ?? false
//
//                    // 여기에서 userLocation 처리는 예시를 생략했습니다. 필요하다면 GeoPoint로부터 latitude와 longitude를 추출합니다.
//
//                    let timeBox = TimeBox(
//                        id: id,
//                        uid: uid,
//                        userName: userName,
//                        imageURL: imageURL,
//                        userLocation: nil, // GeoPoint를 처리하여 설정
//                        description: description,
//                        tagFriendName: tagFriendName,
//                        createTimeCapsuleDate: createTimeCapsuleDate,
//                        openTimeCapsuleDate: openTimeCapsuleDate,
//                        isOpened: isOpened
//                    )
//                    timeBox.append(capsule)
//                }
//                self.capsules = timeBox
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
//
//    
//    private func observeFriendRequests() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        let db = Firestore.firestore()
//        db.collection("friendRequests").whereField("receiverUid", isEqualTo: userId)
//            .addSnapshotListener { [weak self] querySnapshot, error in
//                guard let self = self else { return }
//                if let error = error {
//                    print("Error observing friend requests: \(error.localizedDescription)")
//                    return
//                }
//                print("observeSuccess")
//                // 여기서 fetchFriendRequests를 다시 호출하여 데이터를 최신 상태로 유지할 수 있습니다.
//                self.fetchFriendRequests()
//            }
//    }
//    
//    private func updateUI() {
//        DispatchQueue.main.async {
//            let hasFriendRequests = !self.friendRequests.isEmpty
//            self.tableView.isHidden = !hasFriendRequests
//            if hasFriendRequests {
//                self.tableView.reloadData()
//                print("reloadDataSuccess")
//            }
//            print("UI Updated: \(hasFriendRequests ? "Showing friend requests" : "No friend requests")")
//        }
//    }
//
//    
//    // MARK: - UITableViewDataSource
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2 // 친구 요청과 다가오는 캡슐 섹션
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0:
//            return friendRequests.count
//        case 1:
//            return timeBox.count
//        default:
//            return 0
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         switch indexPath.section {
//         case 0:
//             guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else {
//                 return UITableViewCell()
//             }
//             let user = friendRequests[indexPath.row]
//             cell.configure(with: user, viewModel: viewModel)
//             cell.acceptFriendRequestAction = { [weak self] in
//                 self?.acceptFriendRequest(forUser: user)
//             }
//             return cell
//         case 1:
//             let cell = tableView.dequeueReusableCell(withIdentifier: "CapsuleCell", for: indexPath) as! CapsuleTableViewCell
//             let capsule = timeBox[indexPath.row]
//             cell.configure(with: capsule)
//             return cell
//         default:
//             return UITableViewCell()
//         }
//     }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
//        headerView.backgroundColor = UIColor.white
//        
//        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: 40))
//        label.font = UIFont.boldSystemFont(ofSize: 24)
//        label.textColor = UIColor.black
//        
//        if section == 0 {
//            label.text = "친구요청"
//            
//        } else if section == 1 {
//            label.text = "다가오는 캡슐"
//        }
//        
//        headerView.addSubview(label)
//        return headerView
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40 // 헤더의 높이 설정
//    }
//    
//    
//    func acceptFriendRequest(forUser user: User) {
//        guard let currentUserID = Auth.auth().currentUser?.uid else {
//            print("Error: Current user not found.")
//            return
//        }
//        
//        viewModel.acceptFriendRequest(fromUser: user.uid, forUser: currentUserID) { success, error in
//            if success {
//                // Handle successful request
//                print("Friend request accepted successfully.")
//                // Update UI or perform any other action
//            } else if let error = error {
//                print("Failed to accept friend request: \(error.localizedDescription)")
//                // Handle error if needed
//            }
//        }
//    }
}
