//
//  FriendsSelectionViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/22/24.
//

import UIKit
import Combine
import Kingfisher

class FriendsSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var viewModel = FriendsViewModel()
    var selectedFriends: [User] = []
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
        
        // 네비게이션 타이틀 라벨 커스터마이징
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
        
        // Fetch friends to display
        viewModel.fetchFriends()

        tableView.register(FriendTableViewCell.self, forCellReuseIdentifier: FriendTableViewCell.identifier)

        // Listen to friends array changes using Combine
        viewModel.$friends
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables) // Store the subscription
        
        // Add a 'Done' button to dismiss the modal and return selected friends
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
        cell.accessoryType = selectedFriends.contains(where: { $0.uid == friend.uid }) ? .checkmark : .none
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = viewModel.friends[indexPath.row]
        
        // 새로운 친구를 선택한 경우 추가
        selectedFriends.append(friend)
        print("친구 \(friend.userName ?? "")가 선택되었습니다.")
        
        // 최대 선택 가능한 친구 수를 체크하여 더 이상 선택할 수 없도록 함
        if selectedFriends.count >= 50 {
            // 현재 선택된 친구 수가 최대인 경우, 다른 셀을 선택할 수 없도록 함
            tableView.allowsSelection = false
        }
        
        // 행을 다시 그리도록 요청하여 체크 마크 업데이트
        tableView.reloadRows(at: [indexPath], with: .none)
        print("현재 선택된 친구들: \(selectedFriends.map { $0.userName ?? "Unknown" })")
    }




    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let friend = viewModel.friends[indexPath.row]
        if let index = selectedFriends.firstIndex(where: { $0.uid == friend.uid }) {
            // 선택된 친구 배열에서 제거
            selectedFriends.remove(at: index)
            print("친구 \(friend.userName ?? "")가 선택 해제되었습니다.")
        }
        print("현재 선택된 친구들: \(selectedFriends.map { $0.userName ?? "Unknown" })")
        tableView.reloadRows(at: [indexPath], with: .none)
    }


    
    @objc private func doneSelectingFriends() {
        print("Selected friends: \(selectedFriends.map { $0.userName ?? "Unknown" })")

        delegate?.didTagFriends(selectedFriends)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // 셀의 높이를 설정
    }
    
}


// MARK: - Extension for FriendsSelectionViewController
extension FriendsSelectionViewController {
    // 선택된 친구 배열을 업데이트하는 메서드
    private func updateSelectedFriends(_ friend: User) {
        if let index = selectedFriends.firstIndex(where: { $0.uid == friend.uid }) {
            // 이미 선택된 친구라면 배열에서 제거
            selectedFriends.remove(at: index)
        } else {
            // 아직 선택되지 않은 친구라면 배열에 추가
            selectedFriends.append(friend)
        }
        print("Current selected friends: \(selectedFriends.map { $0.userName ?? "Unknown" })")
    }
}


protocol FriendsSelectionDelegate: AnyObject {
    func didTagFriends(_ friends: [User])
}
