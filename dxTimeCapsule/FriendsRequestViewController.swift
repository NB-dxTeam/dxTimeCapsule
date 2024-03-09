import UIKit
import FirebaseAuth
import FirebaseFirestore

class FriendsRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var alarmLabel: UILabel!
    private var friendRequests: [User] = []
    private let friendTableView = UITableView()
    private let capsuleTableView = UITableView()
    private let viewModel = FriendsViewModel()
    
    private let noRequestsLabel: UILabel = {
        let label = UILabel()
        label.text = "친구 요청이 없습니다"
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupTableView()
        fetchFriendRequests()
        observeFriendRequests()
    }
    
    func setUI() {
        alarmLabel = UILabel()
        alarmLabel.text = "알람"
        alarmLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        alarmLabel.textAlignment = .left
        
        view.addSubview(alarmLabel)
        
        alarmLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().offset(16)
        }
        
        view.addSubview(noRequestsLabel)
        noRequestsLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        noRequestsLabel.center = view.center
        
        noRequestsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview() // 중앙에 표시되도록
        }
    }
    
    private func setupTableView() {
        friendTableView.delegate = self
        friendTableView.dataSource = self
        friendTableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "FriendRequestCell")
        friendTableView.tableFooterView = UIView() // Removes empty cells
        
        view.addSubview(friendTableView)
        friendTableView.snp.makeConstraints { make in
            make.top.equalTo(alarmLabel.snp.bottom) // 라벨 바로 아래 시작
            make.leading.trailing.equalToSuperview()
        }
        
        capsuleTableView.delegate = self
        capsuleTableView.dataSource = self
        capsuleTableView.tableFooterView = UIView() // Removes empty cells
        
        view.addSubview(capsuleTableView)
        capsuleTableView.snp.makeConstraints { make in
            make.top.equalTo(friendTableView.snp.bottom) // friendTableView 아래 시작
            make.leading.bottom.trailing.equalToSuperview()
        }
    }

    
    private func fetchFriendRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        viewModel.fetchFriendRequests(forUser: currentUserId) { [weak self] users, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let users = users {
                    self.friendRequests = users
                    self.updateUI()
                    self.friendTableView.reloadData()
                    print("fetchDataSuccess")
                } else if let error = error {
                    print("Error fetching friend requests: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func observeFriendRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("friendRequests").whereField("receiverUid", isEqualTo: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error observing friend requests: \(error.localizedDescription)")
                    return
                }
                print("observeSuccess")
                // 여기서 fetchFriendRequests를 다시 호출하여 데이터를 최신 상태로 유지할 수 있습니다.
                self.fetchFriendRequests()
            }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            let hasFriendRequests = !self.friendRequests.isEmpty
            self.friendTableView.isHidden = !hasFriendRequests
            if hasFriendRequests {
                self.friendTableView.reloadData()
                print("reloadDataSuccess")
            }
            print("UI Updated: \(hasFriendRequests ? "Showing friend requests" : "No friend requests")")
        }
    }

    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == friendTableView {
            print(friendRequests.count)
            return friendRequests.count
        } else if tableView == capsuleTableView {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == friendTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else {
                return UITableViewCell()
            }
            
            let user = friendRequests[indexPath.row]
            cell.configure(with: user, viewModel: viewModel)
            cell.acceptFriendRequestAction = { [weak self] in
                self?.acceptFriendRequest(forUser: user)
            }
            
            return cell
        }
        else if tableView == capsuleTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "CapsuleCell")
            cell.textLabel?.text = "다가오는 캡슐 \(indexPath.row + 1)"
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == friendTableView {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
            headerView.backgroundColor = UIColor.lightGray // 헤더의 배경색 설정
            
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: 40))
            label.text = "친구요청"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = UIColor.black // 헤더의 텍스트 설정
            headerView.addSubview(label)
            
            return headerView
        } else if tableView == capsuleTableView {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
            headerView.backgroundColor = UIColor.lightGray // 헤더의 배경색 설정
            
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: 40))
            label.text = "다가오는 캡슐"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = UIColor.black // 헤더의 텍스트 설정
            headerView.addSubview(label)
            
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // 헤더의 높이 설정
    }
    
    
    func acceptFriendRequest(forUser user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: Current user not found.")
            return
        }
        
        viewModel.acceptFriendRequest(fromUser: user.uid, forUser: currentUserID) { success, error in
            if success {
                // Handle successful request
                print("Friend request accepted successfully.")
                // Update UI or perform any other action
            } else if let error = error {
                print("Failed to accept friend request: \(error.localizedDescription)")
                // Handle error if needed
            }
        }
    }
}
