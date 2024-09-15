//
//
// ContentView.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//


import SwiftUI
import Vision

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    private let columns = [GridItem(.flexible(), spacing: 16),GridItem(.flexible(), spacing: 16)]
    @State private var showTaggingSheet = false
    @State private var tagName = ""
    @State private var selectedFace: VNFaceObservation?
    @State private var selectedFaceModelId: UUID?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.base
                    .ignoresSafeArea(.all)
                VStack {
                    if viewModel.permissionGranted {
                        if viewModel.isLoading {
                            CircularProgressView(progress: $viewModel.loadingProgress)
                        } else {
                            VStack {
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(viewModel.faceModels, id: \.id) { faceModel in
                                            VStack {
                                                NavigationLink(destination:
                                                                FaceOverlayViewRepresentable(image: faceModel.image, faceObservations: faceModel.observations, tags: faceModel.tags)
                                                               {
                                                    faceObservation in
                                                    selectedFace = faceObservation
                                                    tagName = faceModel.tags[faceObservation] ?? ""
                                                    selectedFaceModelId = faceModel.id
                                                    showTaggingSheet = true
                                                }
                                                    .frame(width: faceModel.image.size.width, height: faceModel.image.size.height), label: {      FaceGridView(croppedFaceImages: faceModel.croppedFaceImages)
                                                    })
                                            }
                                            .frame(height: 180)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.blue, lineWidth: 1)
                                            )
                                        }
                                    }
                                    .padding()
                                }
                                Button {
                                    Task {
                                        viewModel.clearLastScan()
                                        await viewModel.loadPhotos()
                                    }
                                } label: {
                                    Text("Rescan")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(Color.blue.opacity(0.5))
                                        .cornerRadius(15)
                                        .padding()
                                }
                                .frame(height: 52)
                            }
                            .padding(.top, 44)
                        }
                    }
                    else {
                        PhotoLibraryPermissionView()
                            .task {
                                await viewModel.onAppear()
                            }
                    }
                }
                .sheet(isPresented: $showTaggingSheet) {
                    VStack {
                        Text("Tag Face")
                            .font(.headline)
                            .padding()
                        
                        TextField("Enter name", text: $tagName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        HStack {
                            Button("Cancel") {
                                showTaggingSheet = false
                            }
                            .buttonStyle(.bordered)
                            .padding()
                            
                            Button("Tag") {
                                if let selectedFace = selectedFace, let id = selectedFaceModelId {
                                    viewModel.updateTag(id, for: selectedFace, with: tagName)
                                }
                                showTaggingSheet = false
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                    }
                    .padding()
                    .presentationDetents([.height(200)])
                }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
