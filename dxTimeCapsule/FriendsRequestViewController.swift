import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var alarmLabel: UILabel!
    private var friendRequests: [User] = []
    private let tableView = UITableView()
    private var listener: ListenerRegistration?
    private let viewModel = FriendsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupTableView()
        startMonitoringFriendRequests()
        addLogoToNavigationBar()
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
    
    private func addLogoToNavigationBar() {
        // 로고 이미지 설정
        let logoImage = UIImage(named: "App_Logo")
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        
        // 이미지 뷰의 크기 설정
        let imageSize = CGSize(width: 150, height: 45) // 원하는 크기로 조절
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize) // x값을 0으로 변경하여 왼쪽 상단에 위치하도록 설정
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        containerView.addSubview(imageView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
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

    private func startMonitoringFriendRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("현재 사용자 ID를 가져올 수 없습니다.")
            return
        }

        listener = viewModel.db.collection("users").document(currentUserID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else { return }

                let data = snapshot.data() ?? [:]
                let receivedRequests = data["friendRequestsReceived"] as? [String] ?? []
                let friends = data["friends"] as? [String] ?? []

                // 받은 친구 요청을 처리합니다.
                receivedRequests.forEach { userID in
                    self.viewModel.fetchUser(with: userID) { user in
                        if let user = user {
                            self.friendRequests.append(user)
                            self.tableView.reloadData()
                        }
                    }
                }

                // 보낸 요청 중 수락된 것을 처리합니다.
                let acceptedRequests = friends.filter { (userID) -> Bool in
                    guard let sentRequests = data["friendRequestsSent"] as? [String] else { return false }
                    return sentRequests.contains(userID)
                }

                acceptedRequests.forEach { userID in
                    self.viewModel.fetchUser(with: userID) { user in
                        if let user = user {
                            self.friendRequests.append(user)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
    }

    // MARK: - TableView DataSource and Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else {
            return UITableViewCell()
        }

        let friendRequest = friendRequests[indexPath.row]
        cell.configure(with: friendRequest)

        cell.acceptRequestButtonTapped = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.acceptFriendRequest(fromUser: friendRequest.uid, forUser: Auth.auth().currentUser?.uid ?? "") { success, error in
                if success {
                    print("친구 요청 수락 성공")
                    // 필요한 UI 업데이트 또는 데이터 변경 처리
                } else {
                    print("친구 요청 수락 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                }
            }
        }

        return cell
    }

    deinit {
        listener?.remove()
    }
}
