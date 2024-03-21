import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit
import CoreLocation

class UploadPostViewModel {
    
    // 이미지를 Firebase Storage에 업로드하고, 업로드된 이미지 URL을 반환합니다.
    func uploadPostImage(image: UIImage, uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let timestamp = generateTimestamp()
        let uniqueImageName = "image_\(UUID().uuidString)_\(timestamp)"
        let imagePath = constructImagePath(uid: uid, imageName: uniqueImageName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(.failure(NSError(domain: "PostService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])))
            return
        }
        
        uploadImageData(imageData, at: imagePath, completion: completion)
    }
    
    // 타임박스 데이터를 Firestore에 업로드합니다.
    func uploadTimeBox(uid: String, userName: String, images: [UIImage], location: GeoPoint, addressTitle: String, address: String, description: String, tagFriendUid: [String], tagFriendUserName: [String], createTimeBoxDate: Timestamp, openTimeBoxDate: Timestamp, isOpened: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        var imageURLs: [String] = []
        let uploadGroup = DispatchGroup()
        
        for image in images {
            uploadGroup.enter()
            uploadPostImage(image: image, uid: uid) { result in
                switch result {
                case .success(let imageURL):
                    imageURLs.append(imageURL)
                    uploadGroup.leave()
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            let timeCapsuleData = TimeBox(uid: uid, userName: userName, thumbnailURL: imageURLs.first ?? "", imageURL: imageURLs, location: location, addressTitle: addressTitle, address: address, description: description, createTimeBoxDate: createTimeBoxDate, openTimeBoxDate: openTimeBoxDate, isOpened: isOpened)
            self.saveTimeBoxData(TimeBox: timeCapsuleData, completion: completion)
        }
    }
    
    // MARK: - Private Methods
    
    private func generateTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: Date())
    }
    
    private func constructImagePath(uid: String, imageName: String) -> String {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        return "userTimeBoxImages/\(uid)/posts/\(year)/\(month)/\(day)/\(imageName).jpg"
    }
    
    private func uploadImageData(_ data: Data, at path: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child(path)
        storageRef.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "PostService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    private func saveTimeBoxData(TimeBox: TimeBox, completion: @escaping (Result<Void, Error>) -> Void) {
        let timeCapsuleDataDict: [String: Any] = [
            "uid": TimeBox.uid!,
            "userName": TimeBox.userName!,
            "thumbnailURL": TimeBox.thumbnailURL!,
            "imageURLs": TimeBox.imageURL!,
            "location": TimeBox.location!,
            "addressTitle": TimeBox.addressTitle!,
            "address": TimeBox.address!,
            "description": TimeBox.description!,
            "createTimeBoxDate": TimeBox.createTimeBoxDate!,
            "openTimeBoxDate": TimeBox.openTimeBoxDate!,
            "isOpened": TimeBox.isOpened!
        ]
        
        Firestore.firestore().collection("timeCapsuleTest").addDocument(data: timeCapsuleDataDict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
