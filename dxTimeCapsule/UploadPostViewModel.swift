import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit
import CoreLocation

class UploadPostViewModel {
    
    // 이미지(UIImage를 Firebase Storage에 업로드 이미지 URL(String)을 반환합니다.
    func uploadPostImage(imageURL: UIImage, uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let timestamp = generateTimestamp()
        let uniqueImageName = "image_\(UUID().uuidString)_\(timestamp)"
        let imagePath = constructImagePath(uid: uid, imageName: uniqueImageName)
        
        // UIImage 확장을 사용하여 이미지를 4:5 비율로 조정
        guard let resizedImage = imageURL.resizedToFourFiveRatio(),
              let imageData = resizedImage.jpegData(compressionQuality: 0.75) else {
            completion(.failure(NSError(domain: "PostService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])))
            return
        }
        
        uploadImageData(imageData, at: imagePath, completion: completion)
    }
    
    // 타임박스 데이터를 Firestore에 업로드합니다.
    func uploadTimeBox(id: String, uid: String, userName: String, thumbnailImage: UIImage, imageArray: [UIImage], location: GeoPoint, addressTitle: String, address: String, description: String, tagFriendUid: [String], tagFriendUserName: [String], createTimeBoxDate: Timestamp, openTimeBoxDate: Timestamp, isOpened: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        
        var uploadedImageURLs: [String] = []
        let uploadGroup = DispatchGroup()
        
        // Iterate over each image to upload
        for image in imageArray {
            uploadGroup.enter()
            uploadPostImage(imageURL: image, uid: uid) { result in
                switch result {
                case .success(let uploadedURL):
                    uploadedImageURLs.append(uploadedURL)
                    uploadGroup.leave()
                case .failure(let error):
                    uploadGroup.leave() // Ensure leaving the group on error to avoid deadlock.
                    completion(.failure(error))
                    return
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            // Once all images are uploaded, proceed with the TimeBox creation.
            let timeBox = TimeBox(id: id, uid: uid, userName: userName, thumbnailURL: uploadedImageURLs.first, imageURL: uploadedImageURLs, location: location, addressTitle: addressTitle, address: address, description: description, tagFriendUid: tagFriendUid, tagFriendUserName: tagFriendUserName, createTimeBoxDate: createTimeBoxDate, openTimeBoxDate: openTimeBoxDate, isOpened: isOpened)
            
            self.saveTimeBoxData(TimeBox: timeBox, completion: completion)
        }
    }
    
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
    
    // 타임박스 데이터를 Firestore에 업로드합니다.
    private func saveTimeBoxData(TimeBox: TimeBox, completion: @escaping (Result<Void, Error>) -> Void) {
        let timeCapsuleDataDict: [String: Any] = [
            "uid": TimeBox.uid!,
            "userName": TimeBox.userName!,
            "thumbnailURL": TimeBox.thumbnailURL!,
            "imageURL": TimeBox.imageURL!,
            "location": TimeBox.location!,
            "addressTitle": TimeBox.addressTitle!,
            "address": TimeBox.address!,
            "tagFriendUid": TimeBox.tagFriendUid!,
            "tagFriendUserName": TimeBox.tagFriendUserName!,
            "description": TimeBox.description!,
            "createTimeBoxDate": TimeBox.createTimeBoxDate!,
            "openTimeBoxDate": TimeBox.openTimeBoxDate!,
            "isOpened": TimeBox.isOpened!
        ]
        
        Firestore.firestore().collection("timeCapsules").addDocument(data: timeCapsuleDataDict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
