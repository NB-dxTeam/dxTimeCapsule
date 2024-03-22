import UIKit
import Combine
import Kingfisher

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FriendsSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel = FriendsViewModel()
    var selectedFriends: Set<User> = [] // Use Set instead of Array to avoid duplicates
    weak var delegate: FriendsSelectionDelegate?
    private var cancellables: Set<AnyCancellable> = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FriendTableViewCell.self, forCellReuseIdentifier: FriendTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "친구 목록"
        titleLabel.font = UIFont.pretendardRegular(ofSize: 20)
        titleLabel.textColor = UIColor(hex: "#C82D6B")
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        // 현재 로그인한 사용자의 ID를 가져옵니다.
        if let userId = Auth.auth().currentUser?.uid {
            // 수정된 fetchFriends 함수를 호출합니다.
            viewModel.fetchFriends(forUser: userId) { [weak self] (friends, error) in
                if let error = error {
                    // 에러 처리 로직을 추가할 수 있습니다.
                    print("친구 목록을 가져오는데 실패했습니다: \(error.localizedDescription)")
                    return
                }
                if let friends = friends {
                    DispatchQueue.main.async {
                        self?.viewModel.friends = friends
                        self?.tableView.reloadData()
                    }
                }
            }
        } else {
            // 사용자 로그인 상태가 아닐 때의 처리를 추가할 수 있습니다.
            print("사용자가 로그인하지 않았습니다.")
        }
        tableView.register(FriendTableViewCell.self, forCellReuseIdentifier: FriendTableViewCell.identifier)
        
        viewModel.$friends
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneSelectingFriends))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendTableViewCell.identifier, for: indexPath) as? FriendTableViewCell else {
            return UITableViewCell()
        }
        
        let friend = viewModel.friends[indexPath.row]
        cell.configure(with: friend)
        cell.accessoryType = selectedFriends.contains(friend) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = viewModel.friends[indexPath.row]
        selectedFriends.insert(friend)
        updateCellSelectionState(for: friend, at: indexPath)
        print("친구 \(friend.userName ?? "")가 선택되었습니다.")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let friend = viewModel.friends[indexPath.row]
        selectedFriends.remove(friend)
        updateCellSelectionState(for: friend, at: indexPath)
        print("친구 \(friend.userName ?? "")가 선택 해제되었습니다.")
    }
    
    @objc private func doneSelectingFriends() {
        print("Selected friends: \(selectedFriends.map { $0.userName ?? "Unknown" })")
        delegate?.didTagFriends(Array(selectedFriends))
        dismiss(animated: true, completion: nil)
    }
    
    // Update cell selection state
    private func updateCellSelectionState(for friend: User, at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = selectedFriends.contains(friend) ? .checkmark : .none
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

protocol FriendsSelectionDelegate: AnyObject {
    func didTagFriends(_ friends: [User])
}
