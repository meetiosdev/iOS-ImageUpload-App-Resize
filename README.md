# ImageResize - iOS Image Upload App

A modern iOS application built with SwiftUI that allows users to capture images from camera or select from gallery, then upload them to a remote API with progress tracking.

## 🚀 Features

- **📸 Camera Integration**: Take photos directly using device camera
- **🖼️ Gallery Selection**: Choose images from photo library
- **☁️ API Upload**: Upload images to remote server with multipart/form-data
- **📊 Progress Tracking**: Real-time upload progress with visual feedback
- **🎨 Modern UI**: Beautiful SwiftUI interface with smooth animations
- **⚡ Async/Await**: Modern concurrency for responsive user experience

## 📱 Screenshots

The app features a clean, intuitive interface with:
- Image preview area
- Camera and gallery selection buttons
- Upload progress indicator
- Success/error alerts

## 🛠️ Technical Stack

- **Framework**: SwiftUI
- **Language**: Swift 5.0+
- **Networking**: URLSession with async/await
- **Target**: iOS 18.1+
- **Architecture**: MVVM (Model-View-ViewModel)

## 📋 Requirements

- iOS 18.1+
- Xcode 16.0+
- Swift 5.0+

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ImageResize.git
   cd ImageResize
   ```

2. **Open in Xcode**
   ```bash
   open ImageResize.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## 🔐 Privacy Permissions

The app requires the following permissions:
- **Camera Access**: To capture photos
- **Photo Library Access**: To select existing images

These permissions are automatically requested when needed.

## 🌐 API Configuration

The app is configured to upload images to:
```
POST https://api.getmyceliumapp.com/api/tiktok/direct-post
```

### Headers:
- `Content-Type: multipart/form-data`
- `X-Requested-With: XMLHttpRequest`
- `Authorization: Bearer [token]`

### Parameters:
- `photo_cover_index`: 0
- `disable_comment`: true
- `description`: "#mycelium #shoe"
- `auto_add_music`: true
- `privacy_level`: "FOLLOWER_OF_CREATOR"
- `title`: "#mycelium #shoe"

## 📁 Project Structure

```
ImageResize/
├── ImageResize/
│   ├── ContentView.swift          # Main UI
│   ├── ImagePickerViewModel.swift # ViewModel for image handling
│   ├── APIManager.swift          # Network layer
│   ├── ImageResizeApp.swift      # App entry point
│   └── Assets.xcassets/          # App assets
└── ImageResize.xcodeproj/        # Xcode project
```

## 🎯 Key Components

### ContentView.swift
- Main UI with image picker buttons
- Progress tracking display
- Alert handling

### ImagePickerViewModel.swift
- Image selection logic
- Upload functionality
- State management

### APIManager.swift
- Multipart form data creation
- Network request handling
- Error management

## 🔄 Usage Flow

1. **Launch App**: Open the ImageResize app
2. **Select Image**: Choose "Take Photo" or "Choose from Gallery"
3. **Preview**: View selected image in the preview area
4. **Upload**: Tap "Upload Image" to send to server
5. **Monitor**: Watch progress bar and receive status feedback

## 🐛 Troubleshooting

### Common Issues:

1. **Camera Permission Denied**
   - Go to Settings > Privacy & Security > Camera
   - Enable access for ImageResize

2. **Photo Library Permission Denied**
   - Go to Settings > Privacy & Security > Photos
   - Enable access for ImageResize

3. **Upload Fails**
   - Check internet connection
   - Verify API endpoint is accessible
   - Check console logs for error details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Swarajmeet Singh**
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- SwiftUI for the modern UI framework
- Apple for the excellent iOS development tools
- The open source community for inspiration and resources

---

⭐ **Star this repository if you find it helpful!** 