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
    
    // Maximum resolution limit (1080p)
    private let maxResolution: CGFloat = 1080
    
    func selectImageFromGallery() {
        isShowingImagePicker = true
    }
    
    func selectImageFromCamera() {
        isShowingCamera = true
    }
    
    /// Resizes image to fit within the maximum resolution limit while maintaining aspect ratio
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        // Get actual pixel dimensions, not point dimensions
        let cgImage = image.cgImage
        let width = CGFloat(cgImage?.width ?? Int(image.size.width))
        let height = CGFloat(cgImage?.height ?? Int(image.size.height))
        
        print("🔍 Original image dimensions: \(width)x\(height) pixels")
        
        // Check if image needs resizing
        if width <= maxResolution && height <= maxResolution {
            print("✅ Image is within limits, no resizing needed")
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = width / height
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if width > height {
            // Landscape image
            newWidth = maxResolution
            newHeight = maxResolution / aspectRatio
        } else {
            // Portrait or square image
            newHeight = maxResolution
            newWidth = maxResolution * aspectRatio
        }
        
        // Ensure dimensions don't exceed max resolution
        if newWidth > maxResolution {
            newWidth = maxResolution
            newHeight = maxResolution / aspectRatio
        }
        if newHeight > maxResolution {
            newHeight = maxResolution
            newWidth = maxResolution * aspectRatio
        }
        
        // Round to whole pixels
        newWidth = round(newWidth)
        newHeight = round(newHeight)
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        print("📐 Resizing to: \(newWidth)x\(newHeight) pixels")
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0) // Use 1.0 scale factor for exact pixel dimensions
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Verify the resized image dimensions
        if let resizedCGImage = resizedImage?.cgImage {
            let finalWidth = resizedCGImage.width
            let finalHeight = resizedCGImage.height
            print("✅ Final resized image: \(finalWidth)x\(finalHeight) pixels")
        }
        
        return resizedImage ?? image
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
            let resizedImage = resizeImageIfNeeded(image)
            
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