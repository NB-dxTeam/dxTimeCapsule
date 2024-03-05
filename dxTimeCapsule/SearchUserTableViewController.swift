import UIKit
import SnapKit
import SDWebImage
import FirebaseAuth

class SearchUserTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private var searchLabel: UILabel!
    private var searchContainerView: UIView!
    
    private let userProfileViewModel = UserProfileViewModel()
    private let friendsViewModel = FriendsViewModel()
    private var searchResults: [User] = []
    
    private var searchDebounceTimer: Timer?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search UserName"
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.backgroundImage = UIImage() // 선 제거
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchUserTableViewCell.self, forCellReuseIdentifier: "userCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchComponents()
        setupTableView()
        
        searchBar.delegate = self
    }
    
    func setupSearchComponents() {
        searchContainerView = UIView()
        searchContainerView.backgroundColor = .white
        
        searchLabel = UILabel()
        searchLabel.text = "검색"
        searchLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        searchLabel.textAlignment = .left
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.init(hex: "#EFEFEF")
            textField.layer.cornerRadius = 15 // 원하는 라디우스 값 설정
            textField.clipsToBounds = true
        }
        
        searchContainerView.addSubview(searchLabel)
        searchContainerView.addSubview(searchBar)
        
        view.addSubview(searchContainerView)
        
        searchContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-70)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(searchBar.snp.bottom)
        }
        
        searchLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(searchLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupTableView() {
        tableView.register(SearchUserTableViewCell.self, forCellReuseIdentifier: "SearchUserCell")
        tableView.rowHeight = 100
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchContainerView.snp.bottom) // 컨테이너 뷰의 바로 아래 시작
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - UISearchBarDelegate
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           // 디바운싱 로직을 여기에 적용
           searchDebounceTimer?.invalidate()
           searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
               self?.performSearch(with: searchText)
           })
       }

       // MARK: - Functions
       private func performSearch(with searchText: String) {
           guard !searchText.isEmpty else {
               searchResults = []
               tableView.reloadData()
               return
           }

           friendsViewModel.searchUsersByUsername(username: searchText) { [weak self] users, error in
               DispatchQueue.main.async {
                   if let error = error {
                       print("Error searching users: \(error.localizedDescription)")
                   } else {
                       self?.searchResults = users ?? []
                       self?.tableView.reloadData()
                   }
               }
           }
       }

       // MARK: - TableView Delegate & DataSource
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return searchResults.count
       }

       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 80
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? SearchUserTableViewCell else {
               return UITableViewCell()
           }
           let user = searchResults[indexPath.row]
           cell.configure(with: user, viewModel: friendsViewModel)

           // 친구 추가/요청 버튼 탭 액션 설정
           cell.friendActionButtonTapAction = { [weak self] in
               guard let strongSelf = self else { return }
               
               // 현재 사용자의 ID를 가져옵니다.
               guard let currentUserId = Auth.auth().currentUser?.uid else {
                   print("현재 사용자 ID를 가져올 수 없습니다.")
                   return
               }

               // 상태에 따라 친구 요청 보내기 또는 친구 요청 수락하기 로직을 실행합니다.
               strongSelf.friendsViewModel.checkFriendshipStatus(forUser: user.uid) { status in
                   DispatchQueue.main.async {
                       switch status {
                       case "친구 추가":
                           // 친구 요청 보내기
                           strongSelf.friendsViewModel.sendFriendRequest(toUser: user.uid, fromUser: currentUserId) { success, error in
                               if success {
                                   print("친구 요청이 성공적으로 보내졌습니다.")
                                   // 필요한 경우 UI 업데이트
                               } else {
                                   print("친구 요청 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                               }
                           }
                       case "요청 수락":
                           // 친구 요청 수락하기
                           strongSelf.friendsViewModel.acceptFriendRequest(fromUser: user.uid, forUser: currentUserId) { success, error in
                               if success {
                                   print("친구 요청이 성공적으로 수락되었습니다.")
                                   // 필요한 경우 UI 업데이트
                               } else {
                                   print("친구 요청 수락 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                               }
                           }
                       default:
                           print("이미 처리된 상태입니다.")
                       }
                   }
               }
           }
           return cell
       }
    
    
}
