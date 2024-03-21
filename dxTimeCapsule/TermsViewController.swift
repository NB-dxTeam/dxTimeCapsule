//
//  TermsViewController.swift
//  dxTimeCapsule
//
//  Created by Lee HyeKyung on 3/14/24.
//


import UIKit
import SnapKit
import SafariServices // 웹 페이지를 열기 위해 필요

protocol TermsViewControllerDelegate: AnyObject {
    func didCompleteSignUp()
}

class TermsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: TermsViewControllerDelegate?
    
    var email: String?
    var password: String?
    var userName: String?
    var profileImage: UIImage?

    private let headerLabel = UILabel()
    private let allAgreeCheckbox = UIButton()
    private let tableView = UITableView()
    private var termsAgreed = [Bool](repeating: false, count: 3)

    private let joinButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableViewHeader()
        setupTableViewFooter()
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
        let headerHeight: CGFloat = 60 // 기존 높이 설정
        let allAgreeHeight: CGFloat = 60 // '모두 동의합니다' 옵션을 위한 추가 높이
        
        // '모두 동의합니다' 옵션을 포함한 새로운 헤더 뷰의 총 높이
        let totalHeaderHeight = headerHeight + allAgreeHeight
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: totalHeaderHeight))
        headerView.backgroundColor = .white
        headerView.isUserInteractionEnabled = true
        
        let headerLabel = UILabel()
        headerLabel.text = "메모리움 이용약관"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerLabel.textColor = .black
        headerView.addSubview(headerLabel)
        
        let allAgreeView = UIView()
        let allAgreeLabel = UILabel()
        allAgreeLabel.text = "모두 동의합니다."
        
        allAgreeView.addSubview(allAgreeLabel)
        allAgreeView.addSubview(allAgreeCheckbox)
        
        headerView.addSubview(allAgreeView)
        headerView.addSubview(allAgreeCheckbox) // allAgreeCheckbox를 headerView에 추가
        
        let separatorView = UIView()
        separatorView.backgroundColor = tableView.separatorColor
        headerView.addSubview(separatorView)
        
        // 레이아웃 제약 조건 설정
        headerLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview().offset(-allAgreeHeight / 2)
        }
        
        allAgreeCheckbox.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(headerLabel.snp.bottom).offset(36)
            make.width.height.equalTo(24)
        }
        
        allAgreeLabel.snp.makeConstraints { make in
            make.left.equalTo(allAgreeCheckbox.snp.right).offset(8)
            make.centerY.equalTo(allAgreeCheckbox.snp.centerY)
        }
        
        allAgreeView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
        
        separatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        tableView.tableHeaderView = headerView
        
        // 초기 상태 업데이트
        updateAllAgreeCheckboxAppearance(isSelected: termsAgreed.allSatisfy { $0 })
        allAgreeCheckbox.addTarget(self, action: #selector(toggleAllAgreeCheckbox), for: .touchUpInside)
    }


    private func setupTableViewFooter() {
        let footerHeight: CGFloat = 50
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight))
        footerView.backgroundColor = .white

        let termsLabel = UILabel()
        termsLabel.text = "이용약관 보기"
        termsLabel.textColor = .gray
        termsLabel.isUserInteractionEnabled = true // 사용자 상호작용 활성화

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openTermsWebPage))
        termsLabel.addGestureRecognizer(tapGesture)

        footerView.addSubview(termsLabel)
        termsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        tableView.tableFooterView = footerView
    }

    private func setupJoinButton() {
        self.configureButton(joinButton, "Complete Sign Up")
        joinButton.setInstagram()
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
    
    
    // MARK: - Update UI State

    private func updateJoinButtonState() {
        // 모든 필수 체크박스가 선택되었는지 확인합니다.
        let isAllRequiredTermsAgreed = termsAgreed[0] && termsAgreed[1]
        
        // 모든 필수 약관에 동의했다면 버튼을 활성화하고, 아니면 비활성화합니다.
        joinButton.isEnabled = isAllRequiredTermsAgreed
        
        if isAllRequiredTermsAgreed {
            joinButton.backgroundColor = UIColor.systemBlue //.setInstagram() // 활성화 상태의 버튼 스타일
        } else {
            joinButton.backgroundColor = .lightGray // 비활성화 상태의 버튼 스타일
        }
    }
    
    private func updateAllAgreeCheckboxAppearance(isSelected: Bool) {
        let symbolName = isSelected ? "checkmark.circle.fill" : "circle"
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfig)
        allAgreeCheckbox.setImage(symbolImage, for: .normal)
    }

    // MARK: - Action Handlers
    
    @objc private func toggleAllAgreeCheckbox() {
        let allAgreed = !termsAgreed.allSatisfy { $0 }
        termsAgreed = [Bool](repeating: allAgreed, count: 3)
        tableView.reloadData()
        updateJoinButtonState()
        updateAllAgreeCheckboxAppearance(isSelected: allAgreed) // 체크박스 외형 업데이트
    }
    
    @objc private func openTermsWebPage() {
        if let url = URL(string: "https://jooyeong.notion.site/816cf16c963b492b96436b21bdea743d") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }

    @objc private func completeSignUp() {
        guard let email = self.email, let password = self.password, let userName = self.userName, let profileImage = self.profileImage else {
            self.presentAlert(title: "Error", message: "Missing information.")
            return
        }
        
        AuthService.shared.signUpWithEmail(email: email, password: password, userName: userName, profileImage: profileImage) { [weak self] result in
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
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "가입 완료!", style: .default))
        present(alert, animated: true)
    }


    
    // MARK: - UITableViewDelegate & UITableViewDataSource

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
        
        let titles = ["서비스 이용약관 동의 (필수)", "개인정보 처리방침 동의 (필수)", "광고성 정보 수신 및 마케팅 활용 동의 (선택)"]
        
        if indexPath.row < termsAgreed.count {
            cell.configure(with: titles[indexPath.row], isChecked: termsAgreed[indexPath.row])
            cell.onCheckboxToggle = { [weak self] isChecked in
                self?.termsAgreed[indexPath.row] = isChecked
                self?.updateJoinButtonState()
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < termsAgreed.count {
            termsAgreed[indexPath.row] = !termsAgreed[indexPath.row]
            tableView.reloadRows(at: [indexPath], with: .automatic)
            updateJoinButtonState()
        }
    }

    private func configureButton(_ button: UIButton, _ title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        
        // 그림자 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 6 // 그림자의 블러 정도 설정 (조금 더 부드럽게)
        button.layer.shadowOpacity = 0.3 // 그림자의 투명도 설정 (적당한 농도로)
        button.layer.shadowOffset =  CGSize(width: 0, height: 3) // 그림자 방향 설정 (아래로 조금 더 멀리)
        
        button.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
}



