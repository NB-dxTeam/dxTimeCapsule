import Firebase

class LocationHistoryViewModel {
    private var db = Firestore.firestore()
    var locations: [LocationHistory] = []

    // 검색 기록 가져오기
    func fetchLocations(completion: @escaping ([LocationHistory]) -> Void) {
        db.collection("locations").order(by: "timestamp", descending: true).getDocuments { [weak self] (querySnapshot, error) in
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
            DispatchQueue.main.async {
                completion(locations)
            }
        }
    }

    // 검색 기록 삭제
    func deleteLocation(withId id: String, completion: @escaping () -> Void) {
        db.collection("locations").document(id).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                completion()
            }
        }
    }
}
