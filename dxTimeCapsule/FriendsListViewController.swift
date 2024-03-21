import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class FriendsListViewController: UIViewController {
    
    private var friendsListLabel: UILabel!
    private let friendsCountLabel = UILabel()
    var tableView: UITableView!
    let db = Firestore.firestore()
    var currentUser: User?
    var friends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableView()
        fetchCurrentUser()
    }
    
    private func setupViews() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white  // 배경색을 흰색으로 설정합니다.
        view.addSubview(backgroundView)
        
        friendsListLabel = UILabel()
        friendsListLabel.text = "Friends List"
        friendsListLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        friendsListLabel.textAlignment = .center
        friendsListLabel.backgroundColor = .white  // 라벨의 배경색도 흰색으로 설정합니다.
        backgroundView.addSubview(friendsListLabel)
        
        // Friends Count Label Setup
        friendsCountLabel.font = .pretendardRegular(ofSize: 14)
        friendsCountLabel.textColor = .darkGray
        friendsCountLabel.textAlignment = .center
        view.addSubview(friendsCountLabel)

        
        // 라벨의 배경 뷰 제약 조건을 설정합니다.
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(friendsCountLabel).offset(20) // 라벨 아래 여백을 추가합니다.
        }
        
        // 라벨의 제약 조건을 설정합니다.
        friendsListLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
        }
        
        // Friends Count Label Constraints
        friendsCountLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsListLabel.snp.bottom).offset(10) // 수정할 부분
            make.left.equalToSuperview().offset(16)
        }

    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendListTableViewCell.self, forCellReuseIdentifier: "FriendCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(friendsCountLabel.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func fetchCurrentUser() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(currentUserID).getDocument { [weak self] snapshot, error in
            guard let self = self, let document = snapshot, document.exists, error == nil else {
                print("Error fetching current user: \(String(describing: error))")
                return
            }
            
            guard let userData = document.data() else { return }
            self.currentUser = User(
                uid: currentUserID,
                userName: userData["username"] as? String ?? "",
                email: userData["email"] as? String ?? "",
                profileImageUrl: userData["profileImageUrl"] as? String
            )
            // 현재 사용자 정보를 성공적으로 가져온 후 친구 목록 조회
            self.fetchFriends()
        }
    }

    private func fetchFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        // 현재 사용자의 친구 목록 조회
        db.collection("users").document(currentUserID).getDocument { [weak self] snapshot, error in
            guard let self = self, let document = snapshot, document.exists, error == nil else {
                print("Error fetching current user: \(String(describing: error))")
                return
            }
            
            // 'friends' 필드에서 친구 ID 목록을 가져옵니다.
            guard let friendsDict = document.get("friends") as? [String: Any] else { return }
            let friendIDs = Array(friendsDict.keys)
            
            var fetchedFriends: [User] = [] // 임시 배열에 친구 정보 저장
            let dispatchGroup = DispatchGroup()
            
            for friendID in friendIDs {
                dispatchGroup.enter()
                self.db.collection("users").document(friendID).getDocument { friendSnapshot, friendError in
                    defer { dispatchGroup.leave() }
                    if let error = friendError {
                        print("Error fetching friend: \(error)")
                        return
                    }
                    if let friendData = friendSnapshot?.data(),
                       let uid = friendData["uid"] as? String,
                       let userName = friendData["userName"] as? String,
                       let email = friendData["email"] as? String,
                       let profileImageUrl = friendData["profileImageUrl"] as? String {
                        let friend = User(uid: uid, userName: userName, email: email, profileImageUrl: profileImageUrl)
                        fetchedFriends.append(friend) // 임시 배열에 친구 정보 추가
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // 모든 비동기 작업 완료 후, 친구 배열 업데이트 및 테이블 뷰 리로드
                self.friends = fetchedFriends
                self.tableView.reloadData()
                
                // 친구 수 라벨 업데이트
                self.friendsCountLabel.text = "친구 \(self.friends.count)명"
            }
        }
    }


}

extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendListTableViewCell
        cell.user = friends[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


