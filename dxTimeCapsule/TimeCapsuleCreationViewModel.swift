import Foundation
import FirebaseFirestore
import FirebaseAuth

class TimeCapsuleCreationViewModel {
    
    private var db = Firestore.firestore()
    
    // 타임캡슐 데이터 저장
    func saveTimeCapsule(timeCapsule: TimeCapsule) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "id": timeCapsule.uid,
            "userId": userId, // 현재 로그인한 사용자의 ID
            "userName": timeCapsule.userName, // 타임박스를 생성한 사용자의 userName
            "imageURL": timeCapsule.imageURL!, // 업로드 장소 이미지 사진의 URL
            "userLocation": timeCapsule.userLocation!, // 사용자 위치
            "description": timeCapsule.description!, // 타임캡슐 설명
            "tagFriends": timeCapsule.tagFriendName!, // 친구 태그 배열
            "createTimeCapsuleDate": timeCapsule.createTimeCapsuleDate, // 생성일
            "openTimeCapsuleDate": timeCapsule.openTimeCapsuleDate, // 개봉일
            "isOpened": timeCapsule.isOpened // 오픈 여부

        ]
        
        db.collection("timeCapsules").addDocument(data: data) { error in
            if let error = error {
                print("Error saving time capsule: \(error.localizedDescription)")
            } else {
                print("Time capsule saved successfully")
            }
        }
    }
    
    // 특정 사용자의 타임캡슐 데이터 가져오기
    func fetchTimeCapsulesForUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("timeCapsules").whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
            }
    }
}
