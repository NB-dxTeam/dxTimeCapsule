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

struct PostUploadView: View {

    @Environment(\.dismiss) var dismiss
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var description: String = ""
    @State private var selectedEmoji: TimeCapsule.Emoji? = TimeCapsule.emojis.first
    @State private var openTimeCapsuleDate = Date()
    @State private var selectedFriends: [String] = []
    @State private var showingFriendsPicker = false
    @State private var currentUser: User?
    @State private var friends: [Friend] = []
    @State private var isPresenting: Bool = false
    @State private var presentationType: PresentationType = .none
    
    enum PresentationType {
        case photoPicker, friendsPicker, none
    }

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
                    
                    Picker("Emoji", selection: $selectedEmoji) {
                        Text("None").tag(TimeCapsule.Emoji?.none) // Explicitly handle nil case
                        ForEach(TimeCapsule.emojis, id: \.self) { emoji in
                            Text("\(emoji.symbol) \(emoji.description)").tag(emoji as TimeCapsule.Emoji?)
                        }
                    }


                    Section(header: Text("Friend Tag")) {
                        Button("Select Friends") {
                            presentationType = .friendsPicker // friendsPicker로 설정
                            isPresenting = true // 시트 표시
                        }
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
            
            .sheet(isPresented: $isPresenting) {
                // presentationType에 따라 적절한 시트 표시
                switch presentationType {
                    case .photoPicker:
                        PhotoPicker(selectedImage: $selectedImage)
                    case .friendsPicker:
                        FriendsPickerView(selectedFriends: $selectedFriends, friends: friends)
                    case .none:
                        EmptyView()
                }
            }
            
            .onAppear {
                fetchFriends()
            }
        }
    }

    
    private func fetchFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Debug: Cannot fetch current user ID")
            return
        }
        print("Debug: Current user ID: \(currentUserID)")
        let db = Firestore.firestore()

        db.collection("users").document(currentUserID).getDocument { document, error in
            if let error = error {
                print("Debug: Error fetching user data: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists else {
                print("Debug: Document does not exist")
                return
            }
            print("Debug: Fetched user document data")
            if let friendIDs = document.get("friends") as? [String], !friendIDs.isEmpty {
                print("Debug: Friend IDs: \(friendIDs)")
                self.friends.removeAll()
                for friendID in friendIDs {
                    db.collection("users").document(friendID).getDocument { document, error in
                        if let error = error {
                            print("Debug: Error fetching friend details for ID \(friendID): \(error.localizedDescription)")
                            return
                        }
                        guard let document = document, document.exists else {
                            print("Debug: Friend document for ID \(friendID) does not exist")
                            return
                        }
                        print("Debug: Fetched friend document data for ID \(friendID)")

                        let friend = Friend(
                            id: friendID,
                            name: document.get("username") as? String ?? "Unknown",
                            profileImageUrl: document.get("profileImageUrl") as? String ?? nil
                        )
                        
                        DispatchQueue.main.async {
                            print("Debug: Adding friend to array: \(friend)")
                            self.friends.append(friend)
                            print("Debug: Current friends array: \(self.friends)")
                        }
                    }
                }
            } else {
                print("Debug: No friend IDs found or friends array is empty")
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



#Preview(body: {
    PostUploadView()
})

