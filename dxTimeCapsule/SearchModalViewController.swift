import UIKit
import SnapKit
import SDWebImage

class SearchModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    private var searchResults: [User] = []
    private let friendsViewModel = FriendsViewModel()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임으로 검색"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "userCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        searchTextField.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        
        searchTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 숨김
        performSearch()
        return true
    }
    
    private func performSearch() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else { return }

        friendsViewModel.searchUsersByNickname(nickname: searchText) { [weak self] users, error in
            DispatchQueue.main.async {
                if let error = error {
                    // 에러 처리 로직 (예: 사용자에게 에러 메시지 표시)
                    print("Error searching users: \(error.localizedDescription)")
                } else {
                    self?.searchResults = users ?? []
                    self?.tableView.reloadData()
                    print("searchResults: \(self?.searchResults ?? [])")
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = searchResults[indexPath.row]
        cell.configure(with: user)
        
        cell.addUserAction = {
            // Firestore에 친구 추가 요청 로직 구현
            print("친구 추가 요청: \(user.nickname)")
        }
        
        return cell
    }

}
