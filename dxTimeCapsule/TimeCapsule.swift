import Foundation
import FirebaseFirestore

struct TimeCapsule {
    var TimeCapsuleId: String // 타임캡슐 고유 ID
    var uid: String // 타임박스를 생성한 사용자의 ID
    var userName : String // 타임박스를 생성한 사용자의 useName
    var tcBoxImageURL: String? // 업로드 장소 이미지 사진의 URL
    var timeCapsuleImageURL: String? // 업로드된 사진의 URL
    var gpslocation: GeoPoint // 위치
    var userLocation: String? // 사용자 위치 정보(직접 입력)
    var userComment: String? // 사용자 코멘트
    var userMood: String // 선택된 기분
    var tagFriend: [String]? // 친구 태그 배열
    var createTimeCapsuleDate: Date // 생성일
    var openTimeCapsuleDate: Date // 개봉일
    var isOpened: Bool //개봉여부
    var timeCapsuleIsOpen: Bool = false // 타임캠슐 오픈 여부

}


/*
 func fetchTimeCapsuleData() {
         let db = Firestore.firestore()
         
         // 로그인한 사용자의 UID를 가져옵니다.
         //    guard let userId = Auth.auth().currentUser?.uid else { return }
         
         let userId = "Lgz9S3d11EcFzQ5xYwP8p0Bar2z2" // 테스트를 위한 임시 UID
         
         // 사용자의 UID로 필터링하고, openDate 필드로 오름차순 정렬한 후, 최상위 1개 문서만 가져옵니다.
         db.collection("timeCapsules")
                 .whereField("uid", isEqualTo: userId)
                // .whereField("isOpened", isEqualTo: false) // isOpened가 false인 경우 필터링
                 .order(by: "openDate", descending: false) // 가장 먼저 개봉될 타임캡슐부터 정렬
                 .limit(to: 1) // 가장 개봉일이 가까운 타임캡슐 1개만 선택
                 .getDocuments { [weak self] (querySnapshot, err) in
                     guard let self = self else { return }
                     
                     if let err = err {
                         print("Error getting documents: \(err)")
                     } else if let document = querySnapshot?.documents.first { // 첫 번째 문서만 사용
                         let userLocation = document.get("userLocation") as? String ?? "Unknown Location"
                         let location = document.get("location") as? String ?? "Unknown address"
                         let tcBoxImageURL = document.get("tcBoxImageURL") as? String ?? ""
                         let openDateTimestamp = document.get("openDate") as? Timestamp
                         let openDate = openDateTimestamp?.dateValue()
                         
                         print("Fetched location name: \(userLocation)")
                         print("Fetched location address: \(location)")
                         print("Fetched photo URL: \(tcBoxImageURL)")
                         print("Fetched open date: \(openDate)")
                         
                         // 메인 스레드에서 UI 업데이트를 수행합니다.
                         DispatchQueue.main.async {
                             self.locationNameLabel.text = userLocation
                             self.locationAddressLabel.text = location
                             
                             // D-Day 계산
                             if let openDate = openDate {
                                 let dateFormatter = DateFormatter()
                                 dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                 dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // UTC+9:00

                                 let today = Date()
                                 let calendar = Calendar.current
                                 let components = calendar.dateComponents([.day], from: today, to: openDate)

                                 if let daysUntilOpening = components.day {
                                     // 날짜 차이에 따라 표시되는 기호를 변경하여 D-Day 표시
                                     let dDayPrefix = daysUntilOpening <= 0 ? "D+" : "D-"
                                     self.dDayLabel.text = "\(dDayPrefix)\(abs(daysUntilOpening))"
                                 }
                             }
                             
                             if !tcBoxImageURL.isEmpty {
                                 guard let url = URL(string: tcBoxImageURL) else {
                                     print("Invalid photo URL")
                                     return
                                 }
                                 
                                 URLSession.shared.dataTask(with: url) { (data, response, error) in
                                     if let error = error {
                                         print("Error downloading image: \(error)")
                                         return
                                     }
                                     
                                     guard let data = data else {
                                         print("No image data")
                                         return
                                     }
                                     
                                     DispatchQueue.main.async {
                                         self.mainTCImageView.image = UIImage(data: data)
                                     }
                                 }.resume()
                             }
                         }
                     }
                 }
         }
     
 */
