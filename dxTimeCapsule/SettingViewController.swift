//
//  settingViewController.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 3/27/24.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation
import Photos

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    let tableView = UITableView()
    let sections = ["권한 설정", "계정 설정"]
    let permissions = ["카메라 설정", "앨범 설정", "GPS 설정", "알림 설정"]
    let accountSettings = ["비밀번호 변경", "회원 탈퇴"]
    let switchStateKey = "SwitchState"
    let cameraSwitch = UISwitch()
    let cameraPermissionKey = "CameraPermissionStatus"
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSwitch()
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.hidesBackButton = true
        navigationItem.title = "Settings"
        setupBackButton()
    }
    
    func setupBackButton() {
        let backButton = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")
        backButton.setBackgroundImage(image, for: .normal)
        backButton.tintColor = UIColor(red: 209/255.0, green: 94/255.0, blue: 107/255.0, alpha: 1)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navigationController?.navigationBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.centerYAnchor.constraint(equalTo: navigationController!.navigationBar.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: navigationController!.navigationBar.leadingAnchor, constant: 20).isActive = true
    }
    
    func setupSwitch() {
        // 이전에 저장된 스위치 상태를 불러옴
        let savedSwitchState = UserDefaults.standard.bool(forKey: cameraPermissionKey)
        cameraSwitch.isOn = savedSwitchState
        cameraSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
    
    // 권한 상태를 UserDefaults에 저장하는 함수
    func savePermissionStatus(isGranted: Bool) {
        UserDefaults.standard.set(isGranted, forKey: cameraPermissionKey)
        print("savePermissionStatus 메서드가 호출되었습니다. 권한 상태: \(isGranted)")
    }
    
    // 아이폰 설정 앱을 열어서 앱의 권한 설정 화면으로 이동하는 함수
    func openAppSettings() {
        guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appSettingsURL) {
            UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Actions
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return permissions.count
        case 1:
            return accountSettings.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SettingCell")
        }
        let contentLabel = UILabel()
        contentLabel.text = indexPath.section == 0 ? permissions[indexPath.row] : accountSettings[indexPath.row]
        cell?.contentView.addSubview(contentLabel)
        
        // 셀의 콘텐츠 레이블 제약 조건 설정
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20) // leading 및 trailing inset 설정
            make.centerY.equalToSuperview() // 콘텐츠 레이블을 셀의 contentView의 중앙에 배치
        }
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: // 카메라 설정
                cell?.accessoryType = .disclosureIndicator
//                let permissionSwitch = UISwitch()
//                let savedSwitchState = UserDefaults.standard.bool(forKey: cameraPermissionKey)
//                permissionSwitch.isOn = savedSwitchState
//                permissionSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
//                cell?.accessoryView = permissionSwitch
            case 1: // 앨범 설정
                cell?.accessoryType = .disclosureIndicator
            case 2: // GPS 설정
                cell?.accessoryType = .disclosureIndicator
            case 3: // 알림 설정
                cell?.accessoryType = .disclosureIndicator
            default:
                break
            }

        }
        
        return cell!
    }

    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            deleteProfileTapped()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            changePassword()
        } else if indexPath.section == 0 {
            switch indexPath.row {
            case 0: // 카메라 설정
                openAppSettings()
               // break // 카메라 설정은 이미 switchValueChanged 메서드에서 처리됨
            case 1: // 앨범 설정
                openAppSettings()
            case 2: // GPS 설정
                openAppSettings()
            case 3: // 알림 설정
                openAppSettings()
            default:
                break
            }
        }
    }
    
    // MARK: - Private Methods
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        guard let cell = sender.superview as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }

        if sender.isOn {
            // 스위치가 켜진 경우
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.savePermissionStatus(isGranted: true)
                        self.showAlert(title: "Success", message: "카메라 권한이 허용되었습니다.")
                        UserDefaults.standard.set(true, forKey: self.cameraPermissionKey)
                    } else {
                        self.savePermissionStatus(isGranted: true)
                        self.showAlert(title: "Success", message: "카메라 권한이 허용되었습니다.")
                        UserDefaults.standard.set(true, forKey: self.cameraPermissionKey)
                    }
                }
            }
        } else {           
            AVCaptureDevice.requestAccess(for: .video) { granted
                in
                DispatchQueue.main.async {
                    if granted {
                    self.savePermissionStatus(isGranted: false)
                    self.showAlert(title: "Success", message: "카메라 권한이 해제되었습니다.")
                        UserDefaults.standard.set(false, forKey: self.cameraPermissionKey)
                    } else {
                        self.savePermissionStatus(isGranted: false)
                        self.showAlert(title: "Success", message: "카메라 권한이 해제되었습니다.")
                        UserDefaults.standard.set(false, forKey: self.cameraPermissionKey)
                    }
                }
            }
        }
    }

    
    @objc private func deleteProfileTapped() {
        let alertController = UIAlertController(title: "회원 탈퇴", message: "정말로 계정을 삭제하시겠습니까?\n 소중한 추억들이 영원히 사라집니다.", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func deleteAccount() {
        // 사용자 ID를 가져옵니다.
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Firestore에서 사용자 데이터 삭제
        let userDocument = Firestore.firestore().collection("users").document(userId)
        userDocument.delete { error in
            if let error = error {
                // Firestore에서 사용자 데이터 삭제 실패 처리
                print("Firestore에서 사용자 데이터 삭제 실패: \(error.localizedDescription)")
                return
            }
            
            // Firebase Storage에서 사용자 이미지 삭제
            let storageRef = Storage.storage().reference().child("userProfileImages/\(userId)")
            storageRef.delete { error in
                if let error = error as NSError? {
                    // Storage 오류 코드 확인
                    if error.domain == StorageErrorDomain && error.code == StorageErrorCode.objectNotFound.rawValue {
                        // 이미지가 존재하지 않는 경우, 오류를 무시하고 계속 진행
                        print("이미지가 존재하지 않으므로 삭제 과정을 건너뜁니다.")
                    } else {
                        // 다른 유형의 오류 처리
                        print("Storage에서 이미지 삭제 실패: \(error.localizedDescription)")
                    }
                    return
                }
                // 이미지 삭제 성공 처리
                print("이미지가 성공적으로 삭제되었습니다.")
            }
            
            // Firebase Authentication에서 사용자 삭제
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    // 사용자 삭제 실패 처리
                    print("사용자 삭제 실패: \(error.localizedDescription)")
                } else {
                    // 성공적으로 모든 작업 완료 후 처리
                    print("사용자 계정 및 데이터 삭제 완료")
                    DispatchQueue.main.async {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                        guard let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                        
                        let loginViewController = LoginViewController()
                        sceneDelegate.window?.rootViewController = loginViewController
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }

    // 비밀번호 변경 기능을 처리하는 메서드
    private func changePassword() {
        let alertController = UIAlertController(title: "비밀번호 변경", message: "현재 비밀번호를 입력해주세요.", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "현재 비밀번호"
            textField.isSecureTextEntry = true
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(cancelAction)

        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let currentPassword = alertController.textFields?.first?.text else { return }
            
            self?.verifyCurrentPassword(currentPassword: currentPassword)
        }
        alertController.addAction(confirmAction)

        present(alertController, animated: true)
    }

    // 현재 비밀번호의 유효성을 확인하는 메서드
    private func verifyCurrentPassword(currentPassword: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)

        // 현재 비밀번호의 유효성을 확인합니다.
        user.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error {
                // 현재 비밀번호가 일치하지 않는 경우
                print("비밀번호 확인 오류: \(error.localizedDescription)")
                self?.showAlert(title: "Error", message: "비밀번호가 올바르지 않습니다.")
            } else {
                // 현재 비밀번호가 일치하는 경우
                self?.presentChangePasswordAlert()
            }
        }
    }

    // 새 비밀번호 입력을 요청하는 메서드
    private func presentChangePasswordAlert() {
        let alertController = UIAlertController(title: "새 비밀번호 입력", message: "새 비밀번호를 입력하세요.", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "새 비밀번호"
            textField.isSecureTextEntry = true
        }

        alertController.addTextField { textField in
            textField.placeholder = "비밀번호 확인"
            textField.isSecureTextEntry = true
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(cancelAction)

        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let newPassword = alertController.textFields?.first?.text,
                  let confirmPassword = alertController.textFields?.last?.text else { return }
            
            self?.updatePassword(newPassword: newPassword, confirmPassword: confirmPassword)
        }
        alertController.addAction(confirmAction)

        present(alertController, animated: true)
    }

    // 새 비밀번호를 설정하는 메서드
    private func updatePassword(newPassword: String, confirmPassword: String) {
        if newPassword.isEmpty || confirmPassword.isEmpty {
            showAlert(title: "Error", message: "비밀번호를 입력하세요.")
            return
        }
        if newPassword != confirmPassword {
            showAlert(title: "Error", message: "비밀번호가 일치하지 않습니다.")
            return
        }
        
        // 새 비밀번호를 Firebase에 업데이트합니다.
        Auth.auth().currentUser?.updatePassword(to: newPassword) { [weak self] error in
            if let error = error {
                // 비밀번호 업데이트 실패 처리
                print("비밀번호 업데이트 실패: \(error.localizedDescription)")
                self?.showAlert(title: "Error", message: "비밀번호 업데이트에 실패했습니다.")
            } else {
                // 비밀번호 업데이트 성공 처리
                print("비밀번호가 성공적으로 업데이트되었습니다.")
                self?.showAlert(title: "Success", message: "비밀번호가 성공적으로 변경되었습니다.")
            }
        }
    }

    // 경고창을 표시하는 메서드
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default))
        present(alertController, animated: true)
    }
    
    // MARK: - Section Header Methods
    
    // 섹션 헤더 뷰를 반환하는 메서드
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
         let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.width - 30, height: headerView.frame.height))
             headerLabel.text = sections[section] // 섹션 제목 설정
             headerLabel.font = UIFont.boldSystemFont(ofSize: 20) // 폰트 크기 조정
             headerLabel.textColor = .black // 텍스트 색상 설정
             headerView.addSubview(headerLabel) // 섹션 헤더 뷰에 레이블 추가
             headerLabel.snp.makeConstraints { make in
                 make.leading.trailing.equalToSuperview().inset(20) // leading 및 trailing inset 설정
                 make.centerY.equalToSuperview() // 섹션 헤더 레이블을 섹션 헤더 뷰의 중앙에 배치
                }
                
                return headerView // 완성된 섹션 헤더 뷰 반환
            }
            
    // 섹션 헤더 높이 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // 섹션 헤더의 높이 설정
      }
    }
