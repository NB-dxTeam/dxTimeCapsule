import UIKit

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SnapKit

class PostWritingViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    var selectedImage: UIImage?
    var userProfileImageView: UIImageView!
    var userNameLabel: UILabel!
    var friends: [User] = []
    
    
    
    // MARK: - UI Components
    // Title Label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "타임캡슐 생성 위치를 확인해주세요!"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "내용"
        label.textColor = UIColor(hex: "#C82D6B")
        return label
    }()
    
    private let descriptionTextView: UITextView = {
         let textView = UITextView()
         textView.font = .systemFont(ofSize: 16)
         textView.layer.borderColor = UIColor.lightGray.cgColor
         textView.layer.borderWidth = 1
         textView.layer.cornerRadius = 8
         textView.textColor = .lightGray
         return textView
     }()
    
    private let openDateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "박스 개봉 날짜"
        label.textColor = UIColor(hex: "#C82D6B")
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        return dp
    }()
    
    private let tagFriendsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("친구 태그", for: .normal)
        button.setTitleColor(UIColor(hex: "#C82D6B"), for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(ofSize: 16)
        button.backgroundColor = .white.withAlphaComponent(0.85)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let taggedFriendsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = "태그된 친구: 없음"
        return label
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("타임박스 만들기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        return button
    }()
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        setupUI()
        descriptionTextView.delegate = self
        setupGestures()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionTitleLabel, descriptionTextView, openDateTitleLabel, datePicker, tagFriendsButton, taggedFriendsLabel, createButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    private func setupConstraints() {
        
        descriptionTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        openDateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(40)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(openDateTitleLabel.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(40)
        }
        
        tagFriendsButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        taggedFriendsLabel.snp.makeConstraints { make in
            make.top.equalTo(tagFriendsButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        
        createButton.snp.makeConstraints { make in
            make.top.equalTo(taggedFriendsLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50) // Ensure the button has sufficient tap area
        }
    }
    
    
    private func setupButtonActions() {
        tagFriendsButton.addTarget(self, action: #selector(tagfriendListButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTimeCapsule), for: .touchUpInside)
    }
    
    
    private func navigateToMainTabBar() {
        // Create an instance of MainTabBar and present it
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        let mainTabBarVC = MainTabBarView() // Ensure you instantiate your MainTabBar correctly
        window.rootViewController = mainTabBarVC
        window.makeKeyAndVisible()
        
        // Use an animation for a smoother transition
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
    // MARK: - Gestures
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "타임박스에 들어갈 편지를 쓰세요!"
            textView.textColor = .lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Handle text view changes if needed
    }
    
    
    // MARK: - Button Actions
    @objc func tagfriendListButtonTapped() {
        let tagFriendListViewController = TagFriendsListViewController()
        tagFriendListViewController.delegate = self
        self.present(tagFriendListViewController, animated: true, completion: nil)
    }
    
    @objc private func createTimeCapsule() {
        // Your logic to create the time capsule
        
        // After creation logic, show success alert
        let alert = UIAlertController(title: "완료되었습니다", message: "타임박스가 성공적으로 생성되었습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // Transition to the main tab bar controller
            self.transitionToMainTabBar()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func transitionToMainTabBar() {
        // Assuming `MainTabBarController` is your tab bar controller's class
        let mainTabBar = MainTabBarView()
        mainTabBar.modalPresentationStyle = .fullScreen
        present(mainTabBar, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Pan Gesture Handler
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                view.frame.origin.y = translation.y
            }
        case .ended:
            if velocity.y > 0 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        default:
            break
        }
    }
}

// MARK: - TagFriendsListViewControllerDelegate
extension PostWritingViewController: TagFriendsListViewControllerDelegate {
    func didTagFriends(_ taggedFriends: [User]) {
        self.friends = taggedFriends
        //        updateUI(with: taggedFriends)
    }
}


import SwiftUI
// MARK: - SwiftUI Preview
//struct PostWritingViewControllerPreview1: PreviewProvider {
//    static var previews: some View {
//        PostWritingViewController().toPreview()
//    }
//}
