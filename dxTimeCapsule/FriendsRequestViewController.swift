import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel = FriendsViewModel()
    private var friendRequests: [User] = []
    private var friends: [User] = []
    private var alarmLabel: UILabel!
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "FriendRequestCell")
        return tableView
    }()
    
    private var friendRequestsListener: ListenerRegistration?
    private var friendshipsListener: ListenerRegistration?
    
    private func startMonitoringFriendRequests(forUser userId: String) {
        friendRequestsListener = viewModel.db.collection("friendRequests")
            .whereField("receiverUid", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let strongSelf = self else { return }
                
                // 오류 처리
                if let error = error {
                    print("친구 요청을 불러오는 중 오류 발생: \(error.localizedDescription)")
                    return
                }
                
                var updatedFriendRequests: [User] = []
                let group = DispatchGroup()
                
                snapshot?.documents.forEach { document in
                    group.enter()
                    let senderId = document.get("senderUid") as? String ?? ""
                    strongSelf.viewModel.fetchUser(with: senderId) { user in
                        if let user = user, !updatedFriendRequests.contains(where: { $0.uid == user.uid }) {
                            updatedFriendRequests.append(user)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    strongSelf.friendRequests = updatedFriendRequests
                    strongSelf.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
            }
        
    }
    
    private func startMonitoringFriendships(forUser userId: String) {
        friendshipsListener = viewModel.db.collection("friendships")
            .whereField("userUids", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let strongSelf = self else { return }
                // 오류 처리
                if let error = error {
                    print("친구 관계를 불러오는 중 오류 발생: \(error.localizedDescription)")
                    return
                }
                
                var updatedFriends: [User] = []
                let group = DispatchGroup()
                
                snapshot?.documents.forEach { document in
                    let userUids = document.get("userUids") as? [String] ?? []
                    userUids.forEach { friendUserId in
                        if friendUserId != userId {
                            group.enter()
                            strongSelf.viewModel.fetchUser(with: friendUserId) { user in
                                if let user = user, !updatedFriends.contains(where: { $0.uid == user.uid }) {
                                    updatedFriends.append(user)
                                }
                                group.leave()
                            }
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    strongSelf.friends = updatedFriends
                    strongSelf.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
            }
    }
    
    deinit {
        friendRequestsListener?.remove() // 리스너 제거
        friendshipsListener?.remove() // 리스너 제거
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userId = Auth.auth().currentUser?.uid {
            startMonitoringFriendRequests(forUser: userId)
            startMonitoringFriendships(forUser: userId)
        }
        setUI()
        setupTableView()
        fetchFriendRequests()
        fetchFriends()
    }
    
    func setUI() {
        alarmLabel = UILabel()
        alarmLabel.text = "알람"
        alarmLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        alarmLabel.textAlignment = .left
        view.addSubview(alarmLabel)
        
        alarmLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-70)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "FriendRequestCell")
        tableView.rowHeight = 80
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(alarmLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func fetchFriendRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        viewModel.fetchFriendRequests(forUser: userId) { [weak self] users, error in
            if let users = users {
                self?.friendRequests = users
                DispatchQueue.main.async {
                    self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
            } else if let error = error {
                // Handle error
            }
        }
    }
    
    private func fetchFriends() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        viewModel.fetchFriends(forUser: userId) { [weak self] users, error in
            if let users = users {
                self?.friends = users
                DispatchQueue.main.async {
                    self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
            } else if let error = error {
                // Handle error
            }
        }
    }
    
    // MARK: - TableView DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 친구 요청 섹션과 친구 목록 섹션
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return max(friendRequests.count, 1) // 최소한 한 행은 있어야 함
        } else {
            return max(friends.count, 1) // 최소한 한 행은 있어야 함
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 친구 요청이 없는 경우
        if indexPath.section == 0 && friendRequests.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath)
            cell.textLabel?.text = "현재 추가 요청이 없습니다"
            cell.selectionStyle = .none
            return cell
        }
        
        // 실제 친구 요청이 있는 경우
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.section == 0, !friendRequests.isEmpty {
            let friendRequest = friendRequests[indexPath.row]
            cell.user = friendRequest // 새로 추가된 속성에 친구 요청 데이터 할당
            cell.configure(with: friendRequest)
        } else if indexPath.section == 1, !friends.isEmpty {
            let friend = friends[indexPath.row]
            cell.user = friend // 이 부분은 필요에 따라 조정
            cell.configure(with: friend)
        }
        
        cell.acceptRequestButtonTapped = { [weak self] in
            guard let strongSelf = self else { return }
            if let fromUserId = cell.user?.uid, let currentUserId = Auth.auth().currentUser?.uid {
                strongSelf.viewModel.acceptFriendRequest(fromUser: fromUserId, forUser: currentUserId) { success, error in
                    if success {
                        print("친구 요청 수락 성공")
                        // 필요한 UI 업데이트 또는 데이터 변경 처리
                    } else {
                        print("친구 요청 수락 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    }
                }
            }
            
            
        }
        return cell
    }
}

