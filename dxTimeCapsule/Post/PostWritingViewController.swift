import UIKit
import FirebaseFirestore
import FirebaseStorage
import SnapKit 

class PostWritingViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    var selectedImage: UIImage?
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "Select Open Date"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textColor = .lightGray
        textView.text = "타임박스에 들어갈 편지를 쓰세요!"
        return textView
    }()
    
    private let timeCapsuleDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("타임박스 만들기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        setupViews()
        setupGestures()

        createButton.addTarget(self, action: #selector(createTimeCapsule), for: .touchUpInside)
        descriptionTextView.delegate = self
        updateCreateButtonState() // 초기 상태 설정
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createButton.backgroundColor = UIColor(hex: "#D53369").withAlphaComponent(0.85)
    }
    // MARK: - Setup
    private func setupViews() {
        navigationItem.title = "타임캡슐 만들기"

        view.addSubview(descriptionTextView)
        view.addSubview(dateLabel)
        view.addSubview(createButton)

        descriptionTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(30)
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalTo(descriptionTextView)
        }

        createButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }


    
    // MARK: - Functions
    
    private func setupGestures() {
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
          dateLabel.addGestureRecognizer(tapGesture)
      }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Use FirebaseStorage to upload the image and return the URL in the completion handler
    }
    
    @objc private func showDatePicker() {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        
        alertController.view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { [weak self] _ in
            // Format and update dateLabel with the selected date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            self?.dateLabel.text = formatter.string(from: datePicker.date)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func saveTimeCapsule(_ capsule: TimeCapsule) {
        // Use FirebaseFirestore to save the `capsule` object's data to your Firestore database
    }
    
    // descriptionTextView 또는 openDatePicker의 값을 확인하여 버튼을 활성화/비활성화하는 메서드
    private func updateCreateButtonState() {
        let isDescriptionEmpty = descriptionTextView.text?.isEmpty ?? true
        let isImageSelected = selectedImage != nil
        let isDateValid = timeCapsuleDatePicker.date > Date()
        createButton.isEnabled = !isDescriptionEmpty && isImageSelected && isDateValid
    }

    // UITextViewDelegate를 준수하여 텍스트가 변경될 때마다 호출되는 메서드
    func textViewDidChange(_ textView: UITextView) {
        updateCreateButtonState()
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


    // MARK: - Actions
    @objc private func createTimeCapsule() {
        guard let descriptionText = descriptionTextView.text,
              !descriptionText.isEmpty,
              let selectedImage = selectedImage else {
            // Description 또는 Image가 없는 경우 알림을 표시하고 더 이상 진행하지 않음
            showAlert(message: "Please fill in the description and select an image.")
            return
        }
        
        // 선택한 날짜가 현재 날짜보다 이전인지 확인
        guard timeCapsuleDatePicker.date > Date() else {
            showAlert(message: "Please select a future date for opening the time capsule.")
            return
        }

        uploadImage(selectedImage) { [weak self] result in
            switch result {
            case .success(let imageURL):
                let capsule = TimeCapsule(
                    id: UUID().uuidString, // Generate a unique ID for the capsule
                    uid: "User ID", // Obtain from FirebaseAuth.currentUser.uid
                    userName: "User Name", // Obtain from FirebaseAuth.currentUser or another source
                    imageURL: [imageURL],
                    userLocation: nil, // Use CoreLocation to obtain user location
                    description: descriptionText,
                    tagFriends: [], // Implement functionality to select and add friends
                    createTimeCapsuleDate: Date(),
                    openTimeCapsuleDate: self?.timeCapsuleDatePicker.date ?? Date(),
                    isOpened: false
                )
                self?.saveTimeCapsule(capsule)
            case .failure(let error):
                print("Image upload failed: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func datePickerChanged(picker: UIDatePicker) {
        // Handle the date change
    }
}

// Extend UIViewController to add a method for presenting a view controller as a half-modal
extension UIViewController {
    func presentHalfModal(_ viewControllerToPresent: UIViewController, animated: Bool) {
        if let presentationController = viewControllerToPresent.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()] // Adjust size as needed
        }
        self.present(viewControllerToPresent, animated: animated)
    }
}


// MARK: - SwiftUI Preview
import SwiftUI

struct MainTabBarViewPreview4 : PreviewProvider {
    static var previews: some View {
        PostWritingViewController().toPreview()
    }
}
