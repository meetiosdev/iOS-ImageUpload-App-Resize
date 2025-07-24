import Foundation
import UIKit

// MARK: - API Endpoint
enum APIEndpoint: String {
    case tiktokDirectPost = "/api/tiktok/direct-post"
}

// MARK: - API Response
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
}

// MARK: - Media Info
struct MediaInfo {
    let content: MediaContent
    let filename: String
    
    enum MediaContent {
        case image(UIImage)
        case video(URL)
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case noInternet
    case invalidResponse
    case sessionExpired
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection"
        case .invalidResponse:
            return "Invalid response from server"
        case .sessionExpired:
            return "Session expired"
        case .uploadFailed:
            return "Upload failed"
        }
    }
}

// MARK: - API Manager
class APIManager {
    static let shared = APIManager()
    
    private let baseURL = "https://api.getmyceliumapp.com"
    private let token = "606|jwBDiMWR31x8yWwk7eU477oUmC1UjMpGI3wQ2vZ5"
    
    private init() {}
    
    /// Uploads multipart data with progress tracking and async/await support.
    /// - Parameters:
    ///   - endPoint: API endpoint to upload to.
    ///   - parameters: String parameters to include in the request.
    ///   - mediaInfo: Array of MediaInfo objects containing media files to upload.
    ///   - progressHandler: Optional closure to track upload progress (0.0 to 1.0).
    /// - Returns: Decoded response of type T.
    /// - Throws: APIError for various failure scenarios.
    static func uploadMultipartData<T: Decodable>(
        to endPoint: APIEndpoint,
        parameters: [String: Any] = [:],
        mediaInfo: [MediaInfo] = [],
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> T {
        let apiManager = APIManager.shared
        let url = URL(string: apiManager.baseURL + endPoint.rawValue)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("Bearer \(apiManager.token)", forHTTPHeaderField: "Authorization")
        
        // Create multipart body
        var body = Data()
        
        // Add parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            
            let stringValue: String
            switch value {
            case let string as String:
                stringValue = string
            case let int as Int:
                stringValue = String(int)
            case let double as Double:
                stringValue = String(double)
            case let bool as Bool:
                stringValue = bool ? "true" : "false"
            default:
                stringValue = String(describing: value)
            }
            
            body.append(stringValue.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add media files
        for (index, media) in mediaInfo.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            
            switch media.content {
            case .image(let image):
                guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
                
                body.append("Content-Disposition: form-data; name=\"photo_images[]\"; filename=\"\(media.filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
                
            case .video(let url):
                do {
                    let videoData = try Data(contentsOf: url)
                    let fileExtension = url.pathExtension.lowercased()
                    let mimeType: String
                    
                    switch fileExtension {
                    case "mp4":
                        mimeType = "video/mp4"
                    case "mov":
                        mimeType = "video/quicktime"
                    default:
                        mimeType = "video/mp4"
                    }
                    
                    body.append("Content-Disposition: form-data; name=\"video_file\"; filename=\"\(media.filename)\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
                    body.append(videoData)
                    body.append("\r\n".data(using: .utf8)!)
                } catch {
                    print("Failed to process video \(media.filename): \(error)")
                }
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Log request
        print("🔵 [API REQUEST]")
        print("🧭 URL: \(url)")
        print("🔁 Method: POST")
        print("📦 Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("📝 Parameters: \(parameters)")
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("✅ [API RESPONSE]")
        print("📊 Status Code: \(httpResponse.statusCode)")
        
        if let json = try? JSONSerialization.jsonObject(with: data) {
            print("📄 Response: \(json)")
        }
        
        if httpResponse.statusCode == 401 {
            print("❌ Session expired")
            throw APIError.sessionExpired
        }
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            print("❌ Upload failed with status code: \(httpResponse.statusCode)")
            throw APIError.uploadFailed
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
        
        if apiResponse.success, let responseData = apiResponse.data {
            return responseData
        } else {
            throw APIError.invalidResponse
        }
    }
} 