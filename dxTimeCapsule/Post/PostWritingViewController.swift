import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SnapKit
import CoreLocation


class PostWritingViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    var viewModel = UploadPostViewModel() // 뷰 모델 추가
    var selectedImage: [UIImage] = [] // 사용자가 선택한 이미지들
    var thumnailImage: UIImage?
    var timeBoxDescription: String? // 사용자가 입력한 타임박스 설명
    var selectedLocation: CLLocationCoordinate2D? // 사용자가 선택한 위치
    var addressTitle: String? // 사용자 지정 장소명
    var address: String? // 상세주소
    var openTimeBoxDate: Timestamp? // 개봉일
    
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardBold(ofSize: 28)
        label.text = "New TimeBox"
        label.textColor = .black.withAlphaComponent(0.85)
        return label
    }()
    
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
    
    private let addressTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "장소명"
        label.textColor = UIColor(hex: "#C82D6B")
        return label
    }()
    
    private let addressTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "임의의 장소명을 입력하세요. ex)'영희와 처음 만난곳 🤗🧡'"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        return textField
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
    
    private var taggedFriends: [User] = []
    
    private let friendsViewModel = FriendsViewModel() // Assume initialized properly
    
    private let tagFriendsLabel: UILabel = {
        let label = UILabel()
        label.text = "친구 태그"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#C82D6B")
        return label
    }()
    
    private var taggedFriendsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillEqually // 요소들의 너비를 동일하게 분배
        return stackView
    }()
    
    private let tagFriendsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("친구 목록", for: .normal)
        button.backgroundColor = UIColor(hex: "#C82D6B").withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    

    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("타임박스 만들기", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline) // Dynamic type support
        
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
        setupGestures()
        
        descriptionTextView.delegate = self
        
        addressTitleTextField.delegate = self

        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged) // 데이터 피커의 값을 변경할 때마다 호출될 메서드를 설정합니다.
        
        // 타임피커 초기 값을 현재 날짜보다 한 달 뒤로 설정
        let oneMonthLaterDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        datePicker.date = oneMonthLaterDate
        
        // Add pan gesture recognizer to detect downward drag
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createButton.backgroundColor = UIColor(hex: "#C82D6B")
//        createButton.setInstagram()
        
    }
    // MARK: - UI Setup
    private func setupUI() {
        
        
        let stackView = UIStackView(arrangedSubviews: [
            mainTitleLabel,
            descriptionTitleLabel,
            descriptionTextView,
            addressTitleLabel,
            addressTitleTextField,
            tagFriendsLabel,
            taggedFriendsView,
            tagFriendsButton,
            openDateTitleLabel,
            datePicker,
            createButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fill
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        descriptionTextView.snp.makeConstraints{ make in
            make.height.equalTo(150)
        }
        
        datePicker.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        
        tagFriendsButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        taggedFriendsView.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(200)

        }
        
        createButton.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        tagFriendsButton.addTarget(self, action: #selector(tagFriendsButtonTapped), for: .touchUpInside)
        
    }
    
    func uploadLocation() {
        // GeoPoint로 변환
        guard let geoPoint = convertToGeoPoint(location: selectedLocation) else {
            print("Invalid location")
            return
        }
        
        // Firebase Firestore에 GeoPoint 업로드
        let document = Firestore.firestore().collection("locations").document("exampleDocument")
        document.setData(["location": geoPoint]) { error in
            if let error = error {
                print("Error uploading location: \(error.localizedDescription)")
            } else {
                print("Location uploaded successfully!")
            }
        }
    }
    
    // CLLocationCoordinate2D를 GeoPoint로 변환하는 함수
    func convertToGeoPoint(location: CLLocationCoordinate2D?) -> GeoPoint? {
        guard let location = location else { return nil }
        return GeoPoint(latitude: location.latitude, longitude: location.longitude)
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
    
    @objc private func tagFriendsButtonTapped() {
        
        let friendsSelectionVC = FriendsSelectionViewController()
        friendsSelectionVC.delegate = self
        let navController = UINavigationController(rootViewController: friendsSelectionVC)
        
        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium()] // .medium() 또는 .large()로 설정 가능
            }
        }
        
        present(navController, animated: true)
    }
    
    
    // 타임캡슐을 생성하고, 이미지를 업로드한 후 Firestore에 저장합니다.
    @objc private func createButtonTapped(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else {
            print("사용자 아이디를 가져올 수 없습니다.")
            return
        }
        
        guard let locationCoordinate = selectedLocation else {
            print("선택된 위치 정보가 없습니다.")
            return
        }
        
        guard let openDate = openTimeBoxDate else {
            print("개봉일 정보가 없습니다.")
            return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty else {
            print("타임박스 설명이 없습니다.")
            return
        }
        
        guard let addressTitle = addressTitleTextField.text, !addressTitle.isEmpty else {
            print("주소명이 없습니다.")
            return
        }
        
        // 필요한 다른 필드 초기화
        let id = UUID().uuidString // 타임박스의 고유 ID 생성
        let tagFriendUid = taggedFriends.map { $0.uid ?? "" }
        let tagFriendUserName = taggedFriends.map { $0.userName ?? ""}
        let createTimeBoxDate = Timestamp(date: Date()) // 현재 시간을 생성일로 설정
        
        // Firestore에서 사용자의 이름 가져오기
        let userDocRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                if let userName = document.data()?["userName"] as? String {
                    // 사용자의 이름이 성공적으로 가져와졌습니다.
                    
                    // 나머지 코드는 변경하지 않습니다.
                    let geocoder = CLGeocoder()
                    
                    let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                    
                    geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ko_KR")) { [weak self] (placemarks, error) in
                        guard let self = self else { return }
                        if let error = error {
                            print("Geocoding error: \(error.localizedDescription)")
                            return
                        }
                        guard let placemark = placemarks?.first, let address = placemark.name else {
                            print("No address found.")
                            return
                        }
                        
                        self.address = address // 상세 주소 저장
                        
                        // 상세 주소와 사용자가 입력한 주소명을 사용하여 타임캡슐 업로드
                        self.viewModel.uploadTimeBox(
                            id: id,
                            uid: currentUser.uid,
                            userName: userName,
                            imageURL: self.selectedImage,
                            location: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                            addressTitle: addressTitle,
                            address: address,
                            description: description,
                            tagFriendUid: tagFriendUid, // 태그된 친구 UID 배열 전달
                            tagFriendUserName: tagFriendUserName, // 태그된 친구 이름 배열 전달
                            createTimeBoxDate: createTimeBoxDate,
                            openTimeBoxDate: openTimeBoxDate!,
                            isOpened: false,
                            completion: { result in
                                switch result {
                                case .success():
                                    print("타임캡슐 업로드 성공")
                                    // 성공적으로 업로드된 후의 처리 로직 (예: 알림 표시, 화면 전환 등)
                                    self.showAlert(title: "타임캡슐 생성 완료", message: "타임캡슐이 성공적으로 생성되었습니다.")
                                case .failure(let error):
                                    print("타임캡슐 업로드 실패: \(error.localizedDescription)")
                                    // 실패 시 처리 로직
                                }
                            }
                        )
                        
                    }
                } else {
                    print("사용자 이름을 Firestore에서 가져올 수 없습니다.")
                }
            } else {
                print("사용자 문서를 찾을 수 없습니다.")
            }
        }
    }
    
    
    // 데이터 피커의 값이 변경될 때 호출되는 메서드
    @objc private func datePickerValueChanged(_ datePicker: UIDatePicker) {
        openTimeBoxDate = Timestamp(date: datePicker.date)
    }
    
    private func createFriendView(for friend: User) -> UIView {
        let container = UIView()

        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)

        let nameLabel = UILabel()
        nameLabel.text = friend.userName
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        // 여기서 Kingfisher를 사용하여 이미지를 로드합니다.
        if let profileImageUrl = friend.profileImageUrl, let url = URL(string: profileImageUrl) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "defaultProfileImage")
        }

        print("Creating view for friend: \(friend.userName ?? "Unknown")")

        return container
    }
    
    
    // 알림창을 표시하는 메서드
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // 사용자가 입력한 주소를 상세 주소로 업데이트하는 함수
    func updateAddressDetails() {
        guard let locationCoordinate = selectedLocation else {
            print("선택된 위치 정보가 없습니다.")
            return
        }
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ko_KR")) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found.")
                return
            }
            
            // 추출된 주소 정보를 활용하여 필요한 부분을 추출하여 상세 주소 업데이트
            var detailedAddress = ""
            if let administrativeArea = placemark.administrativeArea {
                detailedAddress += administrativeArea + " "
            }
            if let locality = placemark.locality {
                detailedAddress += locality + " "
            }
            if let thoroughfare = placemark.thoroughfare {
                detailedAddress += thoroughfare + " "
            }
            if let subThoroughfare = placemark.subThoroughfare {
                detailedAddress += subThoroughfare
            }
            
            // 업데이트된 상세 주소를 저장
            self.address = detailedAddress
        }
    }
    


    // MARK: - UITextFieldDelegate 메서드
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // addressTitleTextField에 대한 검사
        if textField == addressTitleTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            if updatedText.count > 10 {
                // 사용자에게 경고 표시
                showAlert(title: "안내", message: "장소명은 10자를 넘길 수 없습니다.")
                return false
            }
        }
        return true
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

extension PostWritingViewController: FriendsSelectionDelegate {
    func didTagFriends(_ friends: [User]) {
        self.taggedFriends = friends
        updateTaggedFriendsView()
        print("Tagged friends updated: \(taggedFriends.map { $0.userName ?? "Unknown" })")
    }

    func updateTaggedFriendsView() {
        print("Updating tagged friends view with \(taggedFriends.count) friends.")
        // 기존 뷰 제거
        taggedFriendsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 선택된 친구들의 뷰 추가
        for friend in taggedFriends {
            let friendView = createFriendView(for: friend)
            taggedFriendsView.addArrangedSubview(friendView)
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
