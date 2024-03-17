import Foundation
import FirebaseFirestore
import FirebaseAuth

class TimeCapsuleCreationViewModel {
    
    private var db = Firestore.firestore()
    
    // 타임캡슐 데이터 저장
    func saveTimeCapsule(timeCapsule: TimeBox) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "id": timeCapsule.uid,
            "userId": userId, // 현재 로그인한 사용자의 ID
            "userName": timeCapsule.userName, // 타임박스를 생성한 사용자의 userName
            "imageURL": timeCapsule.imageURL!, // 업로드 장소 이미지 사진의 URL
            "userLocation": timeCapsule.userLocation!, // 사용자 위치
            "description": timeCapsule.description!, // 타임캡슐 설명
            "tagFriends": timeCapsule.tagFriendUid!, // 친구 태그 배열
            "createTimeCapsuleDate": timeCapsule.createTimeBoxDate, // 생성일
            "openTimeCapsuleDate": timeCapsule.openTimeBoxDate, // 개봉일
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

struct dDayCalculation {
    func calculateDDay(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    let openDate: Date
    func dDay() -> String {
        let daysUntilOpening = calculateDDay(from: Date(), to: openDate)
        if daysUntilOpening == 0 {

            // (수정) 오늘이 개봉일일 때 "D-day" 반환
            return "D-day"
        } else {
            // 개봉일이 아닐 때는 "D+날짜" 또는 "D-날짜" 반환
            let dDayPrefix = daysUntilOpening < 0 ? "D+" : "D-"
            return "\(dDayPrefix)\(abs(daysUntilOpening))"
        }
    }
}

