import SwiftUI
import UIKit
import PhotosUI

@MainActor
class ImagePickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isShowingImagePicker = false
    @Published var isShowingCamera = false
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var alertTitle = ""
    
    private let imagePicker = UIImagePickerController()
    
    func selectImageFromGallery() {
        isShowingImagePicker = true
    }
    
    func selectImageFromCamera() {
        isShowingCamera = true
    }
    
    func uploadImage() async {
        guard let image = selectedImage else {
            showAlert(title: "Error", message: "Please select an image first")
            return
        }
        
        isUploading = true
        uploadProgress = 0.0
        
        do {
            // Resize image if needed before uploading
            let resizedImage = ImageResize.shared.resize(image: image)
            
            // Log image dimensions for debugging
            let originalSize = image.size
            let resizedSize = resizedImage.size
            print("📸 Image resizing: \(originalSize.width)x\(originalSize.height) -> \(resizedSize.width)x\(resizedSize.height)")
            
            let mediaInfo = [MediaInfo(content: .image(resizedImage), filename: "image.jpg")]
            
            let parameters: [String: Any] = [
                "photo_cover_index": 0,
                "disable_comment": true,
                "description": " #mycelium #shoe",
                "auto_add_music": true,
                "privacy_level": "FOLLOWER_OF_CREATOR",
                "title": " #mycelium #shoe"
            ]
            
            // Create a dummy response type for the upload
            struct UploadResponse: Decodable {
                let success: Bool
                let message: String?
            }
            
            let response: UploadResponse = try await APIManager.uploadMultipartData(
                to: .tiktokDirectPost,
                parameters: parameters,
                mediaInfo: mediaInfo
            ) { progress in
                DispatchQueue.main.async {
                    self.uploadProgress = progress
                }
            }
            
            isUploading = false
            showAlert(title: "Success", message: "Image uploaded successfully!")
            
        } catch {
            isUploading = false
            showAlert(title: "Upload Failed", message: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 