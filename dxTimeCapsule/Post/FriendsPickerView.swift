//
//  FriendsPickerView.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/14/24.
//

import SwiftUI

struct FriendsPickerView: View {
    @Binding var selectedFriends: [String]
    var friends: [Friend]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(friends, id: \.id) { friend in
                Button(action: {
                    if selectedFriends.contains(friend.id) {
                        selectedFriends.removeAll { $0 == friend.id }
                    } else {
                        selectedFriends.append(friend.id)
                    }
                }) {
                    HStack {
                        Text(friend.name)
                        Spacer()
                        if selectedFriends.contains(friend.id) {
                            Image(systemName: "checkmark").foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
