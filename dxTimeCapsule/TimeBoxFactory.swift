//
//  TimeBoxFactory.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 6/27/24.
//

import Foundation
import FirebaseFirestore


class TimeBoxFactory {
    static func createTimeBox(from data: [String: Any], documentID: String) -> TimeBox {
        let geoPoint = data["location"] as? GeoPoint
        return TimeBox(
            id: documentID,
            uid: data["uid"] as? String ?? "",
            userName: data["userName"] as? String ?? "",
            imageURL: data["imageURL"] as? [String],
            location: geoPoint,
            addressTitle: data["addressTitle"] as? String ?? "",
            address: data["address"] as? String ?? "",
            description: data["description"] as? String,
            tagFriendUid: data["tagFriendUid"] as? [String],
            createTimeBoxDate: Timestamp(date: (data["createTimeBoxDate"] as? Timestamp)?.dateValue() ?? Date()),
            openTimeBoxDate: Timestamp(date: (data["openTimeBoxDate"] as? Timestamp)?.dateValue() ?? Date()),
            isOpened: data["isOpened"] as? Bool ?? false
        )
    }
}
