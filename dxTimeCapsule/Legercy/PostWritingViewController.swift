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
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [ descriptionTitleLabel, descriptionTextView, openDateTitleLabel, datePicker, createButton])
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
        
        createButton.snp.makeConstraints { make in
            make.width.equalTo(200)
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
    
    // MARK: - Gestures
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
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
    
    private func transitionToMainTabBar() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = MainTabBarView()
            })
        }
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

// MARK: - SwiftUI Preview
import SwiftUI
struct PostWritingViewControllerPreview1: PreviewProvider {
    static var previews: some View {
        PostWritingViewController().toPreview()
    }
}
