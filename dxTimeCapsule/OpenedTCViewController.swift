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
        setupNavigationBarAppearance()
        setupToolbar()
        setupBackButton()
        navigationItem.title = "Saved memories"
        fetchTimeBoxesInfo()
        // 테이블뷰의 contentInset을 설정하여 툴바 아래로 이동
    }
    
    // MARK: - Toolbar Setup

    private func setupToolbar() {
        // 툴바 인스턴스 생성
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃 사용
        // 툴바 색상 설정
        toolbar.barTintColor = UIColor.systemGray6.withAlphaComponent(0.5)
        // Segmented Control을 UIBarButtonItem으로 변환
        let segmentedControlBarButton = UIBarButtonItem(customView: sortSegmentedControl)
        
        // 툴바 아이템 설정
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
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
        cell.configure(with: timeBox, dDayColor: UIColor.systemGray4)
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
                self?.viewModel.timeBoxes.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                // Handle deletion failure
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
import SwiftUI
struct PreVie178w: PreviewProvider {
    static var previews: some View {
        OpenedTCViewController().toPreview()
    }
}
