import UIKit
import MapKit
import SnapKit

class BottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    // MARK: - Properties
    private let viewModel = LocationHistoryViewModel()
    private var tableView: UITableView!


    private let favoritesLabel = UILabel()
    private let recentsLabel = UILabel()
    private let contentView = UIView() // contentView 추가
    private let searchBar = UISearchBar()


    
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 먼저 contentView를 view에 추가
         setupContentView() // contentView 설정
         setupBottomUI()
         // 나머지 컴포넌트들 초기화 및 설정
         initializeComponents()
         setupTableView()
         fetchLocationHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // showAlert()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    private func initializeComponents() {

    }
    
    // MARK: - UI Configuration
    private func setupLayout(){

    }

    
    private func setupBottomUI() {
        contentView.addSubview(searchBar)
        contentView.addSubview(favoritesLabel)
        contentView.addSubview(recentsLabel)

        // searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search for places"
        
        searchBar.searchTextField.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top) // contentView.safeAreaLayoutGuide 사용
            make.left.right.equalToSuperview()
        }
        
        // favoritesLabel
        favoritesLabel.text = "Favorites"
        favoritesLabel.font = UIFont.pretendardBold(ofSize: 22) // UIFont.pretendardBold 추가
        favoritesLabel.textColor = UIColor(hex: "#D53369")
        
        favoritesLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        // recentsLabel
        recentsLabel.text = "Recents"
        recentsLabel.font = UIFont.pretendardBold(ofSize: 22) // UIFont.pretendardBold 추가
        recentsLabel.textColor = UIColor(hex: "#D53369")

        
        recentsLabel.snp.makeConstraints { make in
            make.top.equalTo(favoritesLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
        }
        
        
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
 

    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BottomSheetCell")
        contentView.addSubview(tableView) // contentView에 추가
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(recentsLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Functions
    private func showAlert() {
        let alert = UIAlertController(title: "알림", message: "타임캡슐 생성 위치를 확인해주세요!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func fetchLocationHistory() {
        viewModel.fetchLocations {
            self.tableView.reloadData()
        }
    }
    
    private func setupSheetPresentation() {
        if let sheetController = self.presentationController as? UISheetPresentationController {
            sheetController.detents = [.small,.medium(), .large()]
            sheetController.prefersEdgeAttachedInCompactHeight = true
            sheetController.largestUndimmedDetentIdentifier = .medium
        }
    }
    

    
 
    // MARK: - Action

    
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomSheetCell", for: indexPath)
        let location = viewModel.locations[indexPath.row]
        cell.textLabel?.text = location.name
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let locationId = viewModel.locations[indexPath.row].id
            viewModel.deleteLocation(withId: locationId) { [weak self] in
                guard let self = self else { return }
                self.viewModel.locations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 사용자가 위치를 선택했을 때의 처리. 예: 상세 정보 보기
    }
    

    // MARK: - Deinitialization
    deinit {
        // 여기에 정리 코드를 추가할 수 있습니다.
    }
}

extension UISheetPresentationController.Detent.Identifier {
    static let small = Self(rawValue: "small")
}

extension UISheetPresentationController.Detent {
    static var small: UISheetPresentationController.Detent {
        Self.custom { context in
            return context.maximumDetentValue * 0.25
        }
    }
}

// MARK: - SwiftUI Preview
import SwiftUI

struct MainTabBarViewPreview1 : PreviewProvider {
    static var previews: some View {
        MainTabBarView().toPreview()
    }
}
