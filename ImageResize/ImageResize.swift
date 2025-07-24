import UIKit

class ImageResize {
    static let shared = ImageResize()
    
    // Maximum resolution limit (1080p)
    private let maxResolution: CGFloat = 1080
    
    private init() {}
    
    /// Resizes the given image to fit within the maximum resolution limit while maintaining aspect ratio
    /// - Parameter image: The UIImage to resize
    /// - Returns: Resized UIImage
    func resize(image: UIImage) -> UIImage {
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
} 