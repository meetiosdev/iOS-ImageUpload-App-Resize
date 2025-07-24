//
//  ContentView.swift
//  ImageResize
//
//  Created by Swarajmeet Singh on 24/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImagePickerViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Image Upload")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Select an image from camera or gallery to upload")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Selected Image Display
                if let selectedImage = viewModel.selectedImage {
                    VStack(spacing: 15) {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        Text("Selected Image")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                } else {
                    // Placeholder
                    VStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(
                                VStack(spacing: 10) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("No image selected")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    // Camera Button
                    Button(action: {
                        viewModel.selectImageFromCamera()
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Take Photo")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Gallery Button
                    Button(action: {
                        viewModel.selectImageFromGallery()
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Choose from Gallery")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    
                    // Upload Button
                    if viewModel.selectedImage != nil {
                        Button(action: {
                            Task {
                                await viewModel.uploadImage()
                            }
                        }) {
                            HStack {
                                if viewModel.isUploading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.up.circle")
                                        .font(.title2)
                                }
                                Text(viewModel.isUploading ? "Uploading..." : "Upload Image")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isUploading ? Color.gray : Color.orange)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isUploading)
                        
                        // Progress Bar
                        if viewModel.isUploading {
                            VStack(spacing: 8) {
                                ProgressView(value: viewModel.uploadProgress)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .scaleEffect(y: 2)
                                
                                Text("\(Int(viewModel.uploadProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $viewModel.isShowingCamera) {
            ImagePicker(selectedImage: $viewModel.selectedImage, sourceType: .camera)
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    ContentView()
}
