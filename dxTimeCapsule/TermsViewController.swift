//
//  TermsViewController.swift
//  dxTimeCapsule
//
//  Created by Lee HyeKyung on 3/14/24.
//


import UIKit
import SnapKit

protocol TermsViewControllerDelegate: AnyObject {
    func didCompleteSignUp()
}

class TermsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: TermsViewControllerDelegate?
    
    // TermsViewController 내에 선언된 변수들
    var email: String?
    var password: String?
    var username: String?
    var profileImage: UIImage?

    // UI 컴포넌트 선언
    private let headerLabel = UILabel()
    private let tableView = UITableView()
    private var termsAgreed = [Bool](repeating: false, count: 4)
    
    private let joinButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableViewHeader()
        
        setupJoinButton() // 버튼 설정 추가
        updateJoinButtonState() // 버튼 상태 초기화
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TermsTableViewCell.self, forCellReuseIdentifier: "TermsTableViewCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview() // left와 right 제약 조건 추가
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // bottom 제약 조건 추가
        }
    }
    
    private func setupTableViewHeader() {
        // 헤더 뷰의 높이를 변경할 수 있습니다.
        let headerHeight: CGFloat = 50
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        headerView.backgroundColor = .white // 헤더의 배경색 설정
        
        // 구분선을 헤더 뷰의 하단에 추가합니다.
        let separatorView = UIView()
        separatorView.backgroundColor = tableView.separatorColor
        headerView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1) // 구분선의 두께
        }
        
        // 레이블을 헤더 뷰에 추가합니다.
        let headerLabel = UILabel()
        headerLabel.text = "메모리움 이용약관"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerLabel.textColor = .black // 글씨색 설정
        headerView.addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16) // 왼쪽 정렬을 위한 오프셋
            make.centerY.equalToSuperview()
        }
        
        // 테이블 뷰의 헤더 뷰로 설정합니다.
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Setup Join Button
    private func setupJoinButton() {
        joinButton.setTitle("Complete Sign Up", for: .normal)
        joinButton.backgroundColor = .systemBlue
        joinButton.layer.cornerRadius = 10
        joinButton.addTarget(self, action: #selector(completeSignUp), for: .touchUpInside)
        view.addSubview(joinButton)
        
        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(50)
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "가입 완료!", style: .default))
        present(alert, animated: true)
    }

    
    // MARK: - Update Join Button State
    private func updateJoinButtonState() {
        // 첫 번째와 두 번째 체크박스가 모두 선택되었는지 확인
        let isJoinEnabled = termsAgreed[0] && termsAgreed[1]
        joinButton.isEnabled = isJoinEnabled
        joinButton.backgroundColor = isJoinEnabled ? .systemBlue : .lightGray
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termsAgreed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsTableViewCell", for: indexPath) as? TermsTableViewCell else {
            return UITableViewCell()
        }
        
        // 셀에 표시할 텍스트를 준비합니다.
        let titles = ["모두 동의 (선택 전체 동의)", "만 14세 이상", "서비스 이용약관 동의 (필수)", "개인정보 처리방침 동의 (필수)", "광고성 정보 수신 및 마케팅 활용 동의"]
        
        // indexPath.row에 따라 적절한 제목을 설정합니다.
        cell.configure(with: titles[indexPath.row], isChecked: termsAgreed[indexPath.row])
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        termsAgreed[indexPath.row] = !termsAgreed[indexPath.row]
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateJoinButtonState()
    }
    
    @objc private func completeSignUp() {
        guard let email = self.email, let password = self.password, let username = self.username, let profileImage = self.profileImage else {
            self.presentAlert(title: "Error", message: "Missing information.")
            return
        }
        
        AuthService.shared.signUpWithEmail(email: email, password: password, username: username, profileImage: profileImage) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                // 회원가입 성공, 델리게이트를 통해 SignUpViewController에 알림
                DispatchQueue.main.async {
                    strongSelf.delegate?.didCompleteSignUp()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    strongSelf.presentAlert(title: "Sign Up Error", message: error.localizedDescription)
                }
            }
        }
    }
    
}
