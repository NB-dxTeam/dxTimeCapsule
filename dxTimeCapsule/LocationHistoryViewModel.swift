import FirebaseFirestore
import FirebaseAuth

class LocationHistoryViewModel {
    private var db = Firestore.firestore()
    var locations: [LocationHistory] = []

    // 위치 검색 기록 업데이트
    func fetchLocations(completion: @escaping () -> Void) {
        db.collection("locationHistory").order(by: "timestamp", descending: true).getDocuments { [weak self] (querySnapshot, error) in
            var locations: [LocationHistory] = []
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let data = document.data()
                    let location = LocationHistory(id: id, dictionary: data)
                    locations.append(location)
                }
            }
            self?.locations = locations
            DispatchQueue.main.async {
                completion()
            }
        }
    }

//    위치 검색 기록 삭제
    func deleteLocation(withId id: String, completion: @escaping () -> Void) {
        db.collection("locationHistory").document(id).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                completion()
            }
        }
    }
}
