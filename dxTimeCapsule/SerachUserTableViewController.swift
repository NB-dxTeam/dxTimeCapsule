import UIKit
import SnapKit

class SerachUserTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var tableView: UITableView!
    var searchBar: UISearchBar!
    var searchLabel: UILabel!
    var searchContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchComponents()
        setupTableView()
    }
    
    func setupSearchComponents() {
        searchContainerView = UIView()
        searchContainerView.backgroundColor = .white
        
        searchLabel = UILabel()
        searchLabel.text = "검색"
        searchLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        searchLabel.textAlignment = .left
        
        searchBar = UISearchBar()
        searchBar.placeholder = "검색"
        searchBar.backgroundImage = UIImage() // 선 제거
        
        searchContainerView.addSubview(searchLabel)
        searchContainerView.addSubview(searchBar)
        
        view.addSubview(searchContainerView)
        
        searchContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
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
    }
    
    func setupTableView() {
        tableView = UITableView()
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
    
    // MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 반환할 row 수 설정
        return 30 // 예시 값
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUserCell", for: indexPath) as? SearchUserTableViewCell else {
            return UITableViewCell()
        }
        
        // 예시 User 데이터
        let user = User(uid: "uid\(indexPath.row)",
                        email: "user\(indexPath.row)@example.com",
                        username: "User \(indexPath.row)",
                        profileImageUrl: "https://example.com/image.png")
        cell.configure(with: user)
        
        // 버튼 액션 설정
        cell.addUserAction = {
            print("친구 추가 요청: \(user.username)")
        }
        
        return cell
    }

    // MARK: - UISearchBarDelegate methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색어가 변경될 때 호출
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 검색 버튼이 클릭될 때 호출
    }
    
    // MARK: - ScrollView Delegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSearchComponents(for: scrollView.contentOffset.y)
    }
    
    func updateSearchComponents(for yOffset: CGFloat) {
        // 스크롤할 때 라벨의 높이를 줄이고 투명도를 감소시킵니다.
        let labelInitialHeight: CGFloat = 26
        let labelCollapsedHeight: CGFloat = 0 // 라벨이 축소됐을 때의 높이
        
        // yOffset이 0보다 클 때만 라벨의 높이와 투명도를 조정합니다.
        if yOffset > 0 {
            let labelHeight = max(labelCollapsedHeight, labelInitialHeight - yOffset)
            searchLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.height.equalTo(labelHeight)
            }
            
            // 투명도를 조절합니다.
            searchLabel.alpha = labelHeight / labelInitialHeight
        } else {
            searchLabel.snp.updateConstraints { make in
                make.height.equalTo(labelInitialHeight)
            }
            searchLabel.alpha = 1.0
        }
        
        view.layoutIfNeeded()
    }
}

