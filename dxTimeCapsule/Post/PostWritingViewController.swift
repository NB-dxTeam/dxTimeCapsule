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
    
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.text = "내용" // "Content"
        label.textColor = UIColor(hex: "#D53369")
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
    
    private var openDateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.text = "박스 개봉 날짜" // "Box Open Date"
        label.textColor = UIColor(hex: "#D53369")
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
        button.setTitle("친구 태그하기", for: .normal)
        button.setTitleColor(UIColor(hex: "#D53369"), for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(ofSize: 16)
        button.backgroundColor = .white.withAlphaComponent(0.85)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("타임박스 만들기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(ofSize: 16)
        button.backgroundColor = UIColor(hex: "#D53369").withAlphaComponent(0.85) // Ensure the UIColor extension for hex is defined
        
        button.layer.cornerRadius = 8
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.isEnabled = false // Start with the button disabled
        return button
    }()
    
    private let taggedFriendsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0 // Allows multiple lines
        label.text = "Tagged Friends: None"
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        setupViews()
        
        descriptionTextView.delegate = self
//        tagFriendsButton.addTarget(self, action: #selector(tagFriendsButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTimeCapsule), for: .touchUpInside)
        tagFriendsButton.addTarget(self, action: #selector(tagfriendListButtonTapped), for: .touchUpInside)

        
        // Add pan gesture recognizer to detect downward drag
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Setup
    private func setupViews() {
        navigationItem.title = "타임캡슐 만들기"
        
        let views = [descriptionTitleLabel, descriptionTextView, openDateTitleLabel, datePicker, tagFriendsButton, createButton, taggedFriendsLabel]
        views.forEach(view.addSubview)
        
        descriptionTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        openDateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(30)
            
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(openDateTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(openDateTitleLabel)
            make.height.equalTo(50)
            
        }
        
        tagFriendsButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(20)
            make.centerY.equalTo(openDateTitleLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        

        createButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(80)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        taggedFriendsLabel.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc func tagfriendListButtonTapped() {
        let tagFriendListViewController = TagFriendsListViewController()
        tagFriendListViewController.delegate = self // Set self as delegate
        self.present(tagFriendListViewController, animated: true, completion: nil)
    }

    
    @objc func tagFriendsButtonTapped() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        print("현재 사용자 ID: \(currentUserUID)의 친구 목록을 가져오는 중...")
        let db = Firestore.firestore()
        db.collection("users").document(currentUserUID).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let userData = document.data()
                let friendUIDs = userData?["friends"] as? [String] ?? []
                print("찾은 친구 UIDs:", friendUIDs)
                self?.fetchFriendDetails(friendUIDs)
            } else {
                print("문서가 존재하지 않습니다.")
            }
        }
    }
     
    
    func fetchFriendsData(for friendUIDs: [String]) {
        // Assuming you have a reference to Firestore database
        let db = Firestore.firestore()
        
        // Create an array to hold user objects for friends
        var friends: [User] = []
        
        let dispatchGroup = DispatchGroup() // Used for asynchronous operations
        
        // Iterate through friend UIDs to fetch each friend's data
        for friendUID in friendUIDs {
            dispatchGroup.enter() // Enter the dispatch group
            
            db.collection("users").document(friendUID).getDocument { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                defer {
                    dispatchGroup.leave() // Leave the dispatch group when done
                }
                
                if let error = error {
                    print("Error fetching friend's data: \(error.localizedDescription)")
                    // Handle the error
                    return
                }
                
                guard let data = snapshot?.data(),
                      let username = data["username"] as? String,
                      let profileImageUrl = data["profileImageUrl"] as? String else {
                    // Handle the case when essential fields are missing
                    return
                }
                
                // Create a user object for the friend
                let friend = User(uid: friendUID, email: "", username: username, friends: nil, profileImageUrl: profileImageUrl, friendRequestsSent: nil, friendRequestsReceived: nil, friendRequestAcceptedDate: nil)
                
                friends.append(friend) // Add the friend to the array
                
                // Update UI with the fetched friend data
                self.updateUI(with: friends)
            }
        }
        
        // Notify when all fetch operations are completed
        dispatchGroup.notify(queue: .main) {
            // All fetch operations completed
            // You can perform any final tasks here if needed
        }
    }
    
    private func fetchFriendDetails(_ friendUIDs: [String]) {
        let db = Firestore.firestore()
        var friends: [User] = []
        
        let group = DispatchGroup()
        friendUIDs.forEach { uid in
            group.enter()
            print("친구 UID \(uid)에 대한 상세 정보를 가져오는 중...")
            db.collection("users").document(uid).getDocument { document, error in
                defer { group.leave() }
                if let document = document, document.exists {
                    if let friendData = document.data() {
                        let friend = User(
                            uid: uid,
                            email: friendData["email"] as? String ?? "",
                            username: friendData["username"] as? String ?? "알 수 없음",
                            friends: nil, // 혹은 필요한 경우 추가 처리
                            profileImageUrl: friendData["profileImageUrl"] as? String,
                            friendRequestsSent: nil,
                            friendRequestsReceived: nil,
                            friendRequestAcceptedDate: nil
                        )
                        friends.append(friend)
                    }
                } else {
                    print("UID \(uid)에 해당하는 친구 문서가 존재하지 않습니다.")
                }
            }
        }
        
        group.notify(queue: .main) {
            print("모든 친구의 상세 정보를 가져왔습니다. 총 친구 수: \(friends.count)")
            // 여기서 UI 업데이트나 친구 목록 표시 처리를 수행합니다.
        }
    }
       
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
         // Update create button state based on text input
     }
    
    // 여기수정하기
    @objc private func createTimeCapsule() {
        // 타임박스 생성 로직 (Firestore에 데이터 저장 등)

        // Firestore에 데이터 저장이 성공했다고 가정하고, 성공 알림창 표시
        let alert = UIAlertController(title: "성공", message: "타임박스가 성공적으로 생성되었습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // 확인 버튼을 누르면 홈 화면으로 이동
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func updateCreateButtonState() {
        let isDescriptionEmpty = descriptionTextView.text.isEmpty || descriptionTextView.text == "타임박스에 들어갈 편지를 쓰세요!"
        let isImageSelected = selectedImage != nil
        createButton.isEnabled = !isDescriptionEmpty && isImageSelected
    }
    
    func updateUI(with friends: [User]) {
        // Assuming you have a way to display friends in the UI
        // You can update the UI to display the list of friends
        // For example, you can use a table view to show the list of friends
    }
    
    func updateTaggedFriendsUI() {
        if friends.isEmpty {
            taggedFriendsLabel.text = "Tagged Friends: None"
        } else {
            let names = friends.map { $0.username }.joined(separator: ", ")
            taggedFriendsLabel.text = "Tagged Friends: \(names)"
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

extension PostWritingViewController: TagFriendsListViewControllerDelegate {
    func didTagFriends(_ taggedFriends: [User]) {
        self.friends = taggedFriends
        updateTaggedFriendsUI() // Update UI with tagged friends
    }
}


// MARK: - SwiftUI Preview (if needed for your development process)
import SwiftUI

struct PostWritingViewControllerPreview: PreviewProvider {
    static var previews: some View {
        PostWritingViewController().toPreview()
    }
}
