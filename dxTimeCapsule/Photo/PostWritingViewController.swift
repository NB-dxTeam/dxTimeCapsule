import UIKit
import FirebaseFirestore
import FirebaseStorage

class PostWritingViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    var selectedImage: UIImage?
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textColor = .lightGray
        textView.text = "Write something memorable..."
        return textView
    }()
    
    private let openDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Time Capsule", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        createButton.addTarget(self, action: #selector(createTimeCapsule), for: .touchUpInside)
        descriptionTextView.delegate = self
    }
    
    
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "Create Time Capsule"
        
        let stackView = UIStackView(arrangedSubviews: [descriptionTextView, openDatePicker, createButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Use FirebaseStorage to upload the image and return the URL in the completion handler
    }
    
    func saveTimeCapsule(_ capsule: TimeCapsule) {
        // Use FirebaseFirestore to save the `capsule` object's data to your Firestore database
    }
    
    // MARK: - Actions
    @objc private func createTimeCapsule() {
        guard let descriptionText = descriptionTextView.text,
              let selectedImage = selectedImage else { return }
        
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
                    openTimeCapsuleDate: self?.openDatePicker.date ?? Date(),
                    isOpened: false
                )
                self?.saveTimeCapsule(capsule)
            case .failure(let error):
                print("Image upload failed: \(error.localizedDescription)")
            }
        }
    }
}
