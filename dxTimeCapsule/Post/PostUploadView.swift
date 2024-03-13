//
//  PostUploadView.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/13/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct Friend: Identifiable, Decodable {
    var id: String
    var name: String
    var profileImageUrl: String
}
struct PostUploadView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var description: String = ""
    @State private var selectedEmoji: TimeCapsule.Emoji?
    @State private var openTimeCapsuleDate = Date()
    @State private var selectedFriends: [String] = []
    @State private var showingFriendsPicker = false

    @State private var friends: [Friend] = []

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        Button("Select Image") {
                            showPhotoPicker = true
                        }
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    Section(header: Text("Description")) {
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }
                    
                    Section(header: Text("Select Emoji")) {
                        Picker("Emoji", selection: $selectedEmoji) {
                            ForEach(TimeCapsule.emojis, id: \.self) { emoji in
                                Text("\(emoji.symbol) \(emoji.description)")
                                    .tag(emoji)
                            }
                        }
                    }

                    Section(header: Text("Friend Tag")) {
                        Button("Select Friends") {
                            showingFriendsPicker = true
                        }
                    }
                    .sheet(isPresented: $showingFriendsPicker) {
                        FriendsPickerView(selectedFriends: $selectedFriends, friends: friends)
                    }

                    Section(header: Text("Box Open Date")) {
                        DatePicker("Open Date", selection: $openTimeCapsuleDate, displayedComponents: .date)
                    }
                }
                .background(Color.white)
                
                Button("Upload") {
                    // Handle upload
                }
                .padding()
            }
            .navigationTitle("Create Post")
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(selectedImage: $selectedImage)
            }
            .onAppear {
//                fetchFriends().insta
            }
        }
    }
    
    private func fetchFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(currentUserID).getDocument { document, error in
            guard let document = document, document.exists, error == nil else {
                print("Error fetching user data: \(error?.localizedDescription ?? "")")
                return
            }
            
            if let friendIDs = document.get("friends") as? [String] {
                self.loadFriendDetails(friendIDs: friendIDs)
            }
        }
    }


    private func loadFriendDetails(friendIDs: [String]) {
        let db = Firestore.firestore()
        for friendID in friendIDs {
            db.collection("users").document(friendID).getDocument { [ self] document, error in
                guard let document = document, document.exists, error == nil else {
                    print("Error fetching friend details: \(error?.localizedDescription ?? "")")
                    return
                }
                let friend = Friend(id: friendID,
                                    name: document.get("username") as? String ?? "",
                                    profileImageUrl: document.get("profileImageUrl") as? String ?? "")
                DispatchQueue.main.async {
                    self.friends.append(friend)
                }
            }
        }
    }

}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
        .foregroundColor(.black)
    }
}


#Preview(body: {
    PostUploadView()
})

