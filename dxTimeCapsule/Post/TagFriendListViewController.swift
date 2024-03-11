import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol TagFriendsListViewControllerDelegate: AnyObject {
    func didTagFriends(_ taggedFriends: [User])
}

class TagFriendsListViewController: UIViewController {
    
    var tableView: UITableView!
    let db = Firestore.firestore()
    var currentUser: User?
    var friends: [User] = []
    weak var delegate: TagFriendsListViewControllerDelegate?
    private let confirmSelectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Selection", for: .normal)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupConfirmSelectionButton()
        fetchCurrentUser()
    }
    
    func confirmSelection() {
        let selectedFriends = tableView.indexPathsForSelectedRows?.compactMap { indexPath -> User? in
            return friends[indexPath.row]
        } ?? []
        
        delegate?.didTagFriends(selectedFriends)
        dismiss(animated: true, completion: nil)
    }
    private func setupConfirmSelectionButton() {
        view.addSubview(confirmSelectionButton)
        confirmSelectionButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(50)
        }
        confirmSelectionButton.addTarget(self, action: #selector(confirmSelectionButtonTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true // Enable multiple selection
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tagFriendCell") // Update to the correct cell class
        view.addSubview(tableView)
        // Constraints setup...
    }

    private func fetchCurrentUser() {
        // Fetch current user data from Firebase
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(currentUserID).getDocument { [weak self] snapshot, error in
            guard let self = self, let document = snapshot, document.exists, error == nil else {
                print("Error fetching current user: \(String(describing: error))")
                return
            }
            
            guard let userData = document.data() else { return }
            self.currentUser = User(
                uid: currentUserID,
                email: userData["email"] as? String ?? "",
                username: userData["username"] as? String ?? "",
                profileImageUrl: userData["profileImageUrl"] as? String
            )
            self.fetchFriends(forUserID: currentUserID)
        }
    }
    
    private func fetchFriends(forUserID userID: String) {
        db.collection("friendships").whereField("userUids", arrayContains: userID).getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents, error == nil else {
                print("Error fetching friends: \(String(describing: error))")
                return
            }
            
            var friendIDs: [String] = []
            for document in documents {
                let userUids = document.get("userUids") as? [String] ?? []
                if let friendID = userUids.first(where: { $0 != userID }) {
                    friendIDs.append(friendID)
                }
            }
            
            var fetchedFriends: [User] = [] // Use a temporary array to store fetched friends
            
            let dispatchGroup = DispatchGroup()
            
            for friendID in friendIDs {
                dispatchGroup.enter()
                self.db.collection("users").document(friendID).getDocument { friendSnapshot, friendError in
                    defer {
                        dispatchGroup.leave()
                    }
                    if let error = friendError {
                        print("Error fetching friend: \(error)")
                        return
                    }
                    if let friendData = friendSnapshot?.data(),
                        let uid = friendData["uid"] as? String,
                        let email = friendData["email"] as? String,
                        let username = friendData["username"] as? String,
                       let imageUrl = friendData["profileImageUrl"] as? String {
                         let friend = User(uid: uid, email: email, username: username, profileImageUrl: imageUrl)
                         fetchedFriends.append(friend) // Append fetched friend to the temporary array
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Wait for all asynchronous tasks to complete
                // After that, update the friends array and reload tableView
                self.friends = fetchedFriends // Update friends array with fetchedFriends
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func confirmSelectionButtonTapped() {
        let selectedFriends = (tableView.indexPathsForSelectedRows ?? []).map { friends[$0.row] }
        delegate?.didTagFriends(selectedFriends)
        dismiss(animated: true, completion: nil)
    }


}

extension TagFriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagFriendCell", for: indexPath) as! TagFriendListTableViewCell
        cell.user = friends[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
