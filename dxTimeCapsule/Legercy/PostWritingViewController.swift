import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SnapKit

class PostWritingViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    var viewModel = FriendsViewModel()
    var selectedImage: UIImage?
    var userProfileImageView: UIImageView!
    var userNameLabel: UILabel!
    var friends: [User] = []
    var selectedFriends: [User] = []
    var selectedMood: String = ""
    private let moodPickerDelegate = MoodPickerDelegate()
    
    
    // MARK: - UI Components
    //    private let titleLabel: UILabel = {
    //        let label = UILabel()
    //        label.text = "타임캡슐 생성 위치를 확인해주세요!"
    //        label.font = UIFont.preferredFont(forTextStyle: .headline) // Dynamic type support
    //        label.textColor = .black.withAlphaComponent(0.9)
    //        label.textAlignment = .center
    //        label.numberOfLines = 0
    //        label.adjustsFontSizeToFitWidth = true
    //        return label
    //    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "내용"
        label.textColor = UIColor(hex: "#C82D6B")
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body) // Dynamic type support
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textColor = .lightGray
        textView.text = "타임박스에 들어갈 편지를 쓰세요!" // Placeholder text
        return textView
    }()
    
    private let openDateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "박스 개봉 날짜"
        label.textColor = UIColor(hex: "#C82D6B")
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .wheels
        return dp
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("타임박스 만들기", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline) // Dynamic type support
        button.backgroundColor = UIColor(hex: "#C82D6B")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        return button
    }()
    
    private let friendTagTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "친구 태그"
        label.textColor = UIColor(hex: "#C82D6B")
        return label
        
    }()
    
    private lazy var friendTagButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("친구 태그하기", for: .normal)
        button.addTarget(self, action: #selector(tagFriends), for: .touchUpInside)
        return button
    }()
    
    private let moodPickerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "그날의 기분"
        label.textColor = UIColor(hex: "#C82D6B")
        return label
        
    }()
    private lazy var moodPicker: UIPickerView = {
        let picker = UIPickerView()
        // Set the delegate and data source for the picker
        picker.delegate = moodPickerDelegate
        picker.dataSource = moodPickerDelegate
        return picker
    }()
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        descriptionTextView.delegate = self
        setupGestures()
        createButton.addTarget(self, action: #selector(createTimeCapsule), for: .touchUpInside)
        
        // Add pan gesture recognizer to detect downward drag
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        
        
        // FriendsViewModel의 인스턴스 생성
        let friendsViewModel = FriendsViewModel()
        // fetchFriends 메서드 호출
        friendsViewModel.fetchFriends()
        
        // Set the delegate and dataSource of moodPicker
        moodPicker.delegate = moodPickerDelegate
        moodPicker.dataSource = moodPickerDelegate
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [ descriptionTitleLabel, descriptionTextView, openDateTitleLabel, datePicker, friendTagTitleLabel, friendTagButton, moodPickerTitleLabel, moodPicker, createButton])
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
        
        descriptionTextView.snp.makeConstraints{ make in
            make.height.equalTo(100)
        }
        
        datePicker.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        friendTagButton.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        moodPicker.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        createButton.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    private func transitionToMainTabBar() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = MainTabBarView()
            })
        }
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
    
    // MARK: - Button Actions
    @objc private func createTimeCapsule() {
        // Your logic to create the time capsule
        
        // Animation for the create button
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.createButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
        animator.addAnimations({
            self.createButton.transform = .identity
        }, delayFactor: 0.2)
        animator.startAnimation()
        
        // Success alert
        let alert = UIAlertController(title: "완료되었습니다", message: "타임박스가 성공적으로 생성되었습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.transitionToMainTabBar()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func tagFriends() {
        
    }
    
    // MARK: - Pan Gesture Handler
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                // Move the view down with the drag
                view.frame.origin.y = translation.y
            }
        case .ended:
            if velocity.y > 0 {
                // Dismiss the modal if dragged downward with enough velocity
                dismiss(animated: true, completion: nil)
            } else {
                // Reset the view position if drag distance is less than 100 points
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        default:
            break
        }
    }
}


// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension PostWritingViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Emoji.emojis.count
    }
}

class MoodPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    // 이모지 배열 정의
    let emojis = Emoji.emojis // 이 배열은 Emoji 클래스에서 정의되어 있어야 합니다.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return emojis.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        // 각 행에 대한 컨테이너 뷰 생성
        let emojiContainerView = UIView()
        emojiContainerView.layer.cornerRadius = 10 // 모서리 둥글게
        emojiContainerView.layer.masksToBounds = true
        emojiContainerView.backgroundColor = UIColor.systemGray5 // 파일 첨부처럼 보이는 배경색
        
        // 이모지를 위한 레이블 생성
        let emojiLabel = UILabel()
        emojiLabel.font = UIFont.systemFont(ofSize: 24) // 필요에 따라 폰트 크기 조정
        emojiLabel.text = self.emojis[row].symbol // self를 사용하여 현재 인스턴스의 emojis 배열에 접근
        emojiLabel.textAlignment = .center
        
        // 이모지 레이블을 컨테이너 뷰에 추가
        emojiContainerView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor)
        ])
        
        return emojiContainerView
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 기분 선택 처리
        if let viewController = pickerView.delegate as? PostWritingViewController {
            viewController.selectedMood = emojis[row].symbol
        }
    }
}




// MARK: - SwiftUI Preview
import SwiftUI
struct PostWritingViewControllerPreview1: PreviewProvider {
    static var previews: some View {
        PostWritingViewController().toPreview()
    }
}
