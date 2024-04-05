//
//  OpenedTCViewController.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 3/8/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class OpenedTCViewController: UITableViewController {
    
    // MARK: - Properties
    
    var documentId: String?
    private var viewModel = OpenedTCViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupToolbar()
        backButtonNavigationBar()
        sortSegmentedControl.selectedSegmentIndex = 1
        fetchTimeBoxesInfo()

    }
    
    // MARK: - Toolbar Setup

    private func setupToolbar() {
        // 툴바 인스턴스 생성
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃 사용
        // 툴바 색상 설정
        toolbar.barTintColor = UIColor.systemGray6.withAlphaComponent(0.5)
        
//        // Magnify 버튼 생성
//        let magnifyButton = UIButton(type: .custom)
//        magnifyButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
//        magnifyButton.addTarget(self, action: #selector(magnifyButtonTapped), for: .touchUpInside)
//        magnifyButton.tintColor = UIColor.systemGray
//        let magnifyBarButton = UIBarButtonItem(customView: magnifyButton)
        
        // Segmented Control을 UIBarButtonItem으로 변환
        let segmentedControlBarButton = UIBarButtonItem(customView: sortSegmentedControl)
        
        // 툴바 아이템 설정
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
       // toolbar.items = [magnifyBarButton, flexibleSpace, segmentedControlBarButton]
        toolbar.items = [flexibleSpace, segmentedControlBarButton]
        // 툴바의 레이아웃 제약 조건 설정
        toolbar.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(44) // 툴바 높이 설정
            
            // 툴바를 테이블 뷰의 헤더 뷰로 설정
            tableView.tableHeaderView = toolbar
        }
    }

//    @objc func magnifyButtonTapped() {
//        // Magnify 버튼이 탭되었을 때 수행할 동작
//    }

   
    // MARK: - UI Setup
    
    private func setupUI() {
        tableView.register(TimeCapsuleCell.self, forCellReuseIdentifier: TimeCapsuleCell.identifier)
        tableView.separatorStyle = .none
    }
    // MARK: - Data Fetching
    
    private func fetchTimeBoxesInfo() {
        viewModel.fetchTimeBoxesInfo { [weak self] timeBoxes in
            self?.viewModel.timeBoxes = timeBoxes
            self?.tableView.reloadData()
            self?.sortOptionChanged()
        }
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let itemHeight = screenWidth * (11 / 16)
        return itemHeight
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.timeBoxes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCapsuleCell.identifier, for: indexPath) as? TimeCapsuleCell else {
            fatalError("Unable to dequeue TimeCapsuleCell")
        }
        
        let timeBox = viewModel.timeBoxes[indexPath.row]
        cell.configure(with: timeBox, dDayColor: UIColor.systemGray4, controllerType: .OpenedTCViewControllerLogic)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let openCapsuleVC = OpenCapsuleViewController()
        let documentId = viewModel.timeBoxes[indexPath.row].id
        openCapsuleVC.documentId = documentId
        openCapsuleVC.modalPresentationStyle = .fullScreen
        present(openCapsuleVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completionHandler) in
            self?.showDeleteConfirmationAlert(at: indexPath)
            completionHandler(false)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    // MARK: - Actions
    
    @objc private func homeButtonTapped() {
        let tabBarController = MainTabBarView()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    @objc private func sortOptionChanged() {
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0:
            viewModel.currentSortOption = .newestFirst
        case 1:
            viewModel.currentSortOption = .oldestFirst
        default:
            break
        }
        sortTimeBoxesAndReloadTableView()
    }
    
    private func sortTimeBoxesAndReloadTableView() {
        viewModel.sortTimeBoxesAndReloadTableView { [weak self] timeBoxes in
            self?.viewModel.timeBoxes = timeBoxes
            self?.tableView.reloadData()
        }
    }
    
    private func showDeleteConfirmationAlert(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "경고", message: "이 추억은 영원히 기억속으로 사라집니다.\n정말로 이 추억을 삭제하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteCapsule(at: indexPath)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteCapsule(at indexPath: IndexPath) {
        viewModel.deleteCapsule(at: indexPath.row) { [weak self] success in
            if success {
                // 삭제 작업이 성공한 경우에는 그냥 다시 정보를 불러오기
                self?.fetchTimeBoxesInfo()
            } else {
                // 삭제 실패 시 알림 표시
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "삭제 실패", message: "삭제 작업을 완료할 수 없습니다. 다시 시도하시겠습니까?", preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "다시 시도", style: .default) { _ in
                        // 다시 시도하기 위한 작업 수행
                        self?.deleteCapsule(at: indexPath)
                    }
                    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                    alertController.addAction(retryAction)
                    alertController.addAction(cancelAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }




    
    // MARK: - Views
    
    // 세그먼트 컨트롤 정의
    lazy var sortSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["최신순", "오래된순"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(sortOptionChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    // 네비게이션 바 스타일 설정
    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage(named: "gray_line")
    }
    
    // 왼쪽 backButton 설정
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")
        backButton.setBackgroundImage(image, for: .normal)
        backButton.tintColor = UIColor(red: 209/255.0, green: 94/255.0, blue: 107/255.0, alpha: 1)
        backButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 30)
        
        let backButtonBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonBarItem
    }
}

extension OpenedTCViewController {
    func backButtonNavigationBar() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.hidesBackButton = true
        
        // 타이틀 설정
        navigationItem.title = "Saved memories"
        
        // 백 버튼 생성
        let backButton = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")
        backButton.setBackgroundImage(image, for: .normal)
        backButton.tintColor = UIColor(red: 209/255.0, green: 94/255.0, blue: 107/255.0, alpha: 1)
        backButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)

        
        // 내비게이션 바에 백 버튼 추가
         navigationController?.navigationBar.addSubview(backButton)
        
        // 백 버튼의 위치 조정
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.centerYAnchor.constraint(equalTo: navigationController!.navigationBar.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: navigationController!.navigationBar.leadingAnchor, constant: 20).isActive = true
    }
}
