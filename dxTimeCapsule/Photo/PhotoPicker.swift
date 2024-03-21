//
//  PhotoPicker.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/13/24.
//

import PhotosUI
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = (context.coordinator as! any UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                        self.uploadImageToStorage(image) { [weak self] downloadURL in
                            // Handle upload completion if needed
                        }
                    }
                }
            }
        }
        
        func uploadImageToStorage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                print("Failed to convert image to JPEG data")
                completion(nil)
                return
            }
            
            let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image to Storage: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                            completion(nil)
                            return
                        }
                        completion(downloadURL)
                    }
                }
            }
        }

        }
        

}
