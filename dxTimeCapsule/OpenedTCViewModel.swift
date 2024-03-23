//
//  OpenedTCViewModel.swift
//  dxTimeCapsule
//
//  Created by 안유진 on 3/23/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class OpenedTCViewModel {
    
    // MARK: - Properties
    
    // 시간 캡슐 배열
    internal var timeBoxes: [TimeBox] = []
    
    // 정렬 옵션
    enum SortOption {
        case oldestFirst
        case newestFirst
    }
    
    // 현재 설정된 정렬 옵션
    var currentSortOption: SortOption = .oldestFirst
    
    // MARK: - Data Fetching
    
    // Firestore에서 시간 캡슐 정보를 가져오는 메서드
    func fetchTimeBoxesInfo(completion: @escaping ([TimeBox]) -> Void) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("timeCapsules")
            .whereField("uid", isEqualTo: userId)
            .whereField("isOpened", isEqualTo: true)
            .order(by: "openTimeBoxDate", descending: false)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching time boxes: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No time boxes found")
                    completion([])
                    return
                }
                
                let fetchedTimeBoxes = documents.compactMap { doc -> TimeBox? in
                    let data = doc.data()
                    return TimeBox(
                        id: doc.documentID,
                        imageURL: data["imageURL"] as? [String],
                        addressTitle: data["addressTitle"] as? String,
                        createTimeBoxDate: data["createTimeBoxDate"] as? Timestamp,
                        openTimeBoxDate: data["openTimeBoxDate"] as? Timestamp
                    )
                }
                
                print("Fetched \(fetchedTimeBoxes.count) time boxes")
                completion(fetchedTimeBoxes)
            }
    }
    
    // MARK: - Data Processing
    
    // 시간 캡슐을 정렬하고 반환
    func sortTimeBoxes() -> [TimeBox] {
        switch currentSortOption {
        case .newestFirst:
            return timeBoxes.sorted { $0.createTimeBoxDate?.dateValue() ?? Date() > $1.createTimeBoxDate?.dateValue() ?? Date() }
        case .oldestFirst:
            return timeBoxes.sorted { $0.createTimeBoxDate?.dateValue() ?? Date() < $1.createTimeBoxDate?.dateValue() ?? Date() }
        }
    }
    
    // MARK: - Data Manipulation
    
    // 캡슐 삭제
    func deleteCapsule(at index: Int, completion: @escaping (Bool) -> Void) {
        guard let deletedId = timeBoxes[index].id else {
            // 캡슐 정보가 올바르지 않음
            completion(false)
            return
        }
      
        // Firestore에서 해당 캡슐 삭제
        let db = Firestore.firestore()
        db.collection("timeCapsules").document(deletedId).delete { error in
            if let error = error {
                print("Error deleting capsule: \(error)")
                completion(false)
            } else {
                print("Capsule deleted successfully")
                // 데이터 소스에서 삭제된 캡슐 제거
                self.timeBoxes.remove(at: index)
                completion(true)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // 시간 캡슐을 정렬하고 테이블 뷰 다시 로드
    func sortTimeBoxesAndReloadTableView(completion: @escaping ([TimeBox]) -> Void) {
        let sortedTimeBoxes = sortTimeBoxes()
        completion(sortedTimeBoxes)
    }
}
