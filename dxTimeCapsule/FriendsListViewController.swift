import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendsListViewController: UIViewController {
    var tableView: UITableView!
    let db = Firestore.firestore()
    var currentUser: User?
    var friends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        fetchCurrentUser()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendListTableViewCell.self, forCellReuseIdentifier: "FriendCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func fetchCurrentUser() {
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
    
    func fetchFriends(forUserID userID: String) {
        db.collection("friendships").whereField("userUids", arrayContains: userID).getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents, error == nil else {
                print("Error fetching friends: \(error)")
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
