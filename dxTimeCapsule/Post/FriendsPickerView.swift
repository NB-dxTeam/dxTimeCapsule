//
//  FriendsPickerView.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/14/24.
//

import SwiftUI

struct FriendsPickerView: View {
    @Binding var selectedFriends: [String]
    @State var friends: [User]
    
    var body: some View {
        List {
            ForEach(friends, id: \.uid) { friend in
                MultipleSelectionRow(title: friend.userName!, isSelected: selectedFriends.contains(friend.uid!)) {
                    if let index = selectedFriends.firstIndex(of: friend.uid!) {
                        selectedFriends.remove(at: index)
                    } else {
                        selectedFriends.append(friend.uid!)
                    }
                }
            }
        }
        .navigationTitle("Select Friends")
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action:() -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())  // Ensure the entire row is tappable
        .onTapGesture {
            self.action()
        }
    }
}
    
