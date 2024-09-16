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
    @State private var selectedFaceModel: FaceImageModel?
    @State private var isActive = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.base
                    .ignoresSafeArea(.all)
                VStack {
                    if viewModel.permissionGranted {
                        VStack(alignment: .center) {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(viewModel.faceModels, id: \.id) { faceModel in
                                        NavigationLink(
                                            destination:
                                                FaceDetectionView(image: faceModel.image ?? UIImage(), faceObservations: faceModel.observations ?? [], tags: faceModel.tags)
                                            {
                                                faceObservation in
                                                selectedFace = faceObservation
                                                tagName = faceModel.tags[faceObservation] ?? ""
                                                selectedFaceModelId = faceModel.id
                                                showTaggingSheet = true
                                            }
                                            ,isActive: Binding(
                                                get: { selectedFaceModel?.id == faceModel.id && isActive },
                                                set: { isActive = $0 }
                                            )
                                        ) {
                                            VStack {
                                                Image(uiImage: faceModel.thumbnail)
                                                    .resizable()
                                                    .frame(height: 120)
                                            }
                                            .frame(height: 180)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.blue, lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                if faceModel.image == nil {
                                                    Task {
                                                        await viewModel.updateObservations(faceModel.id)
                                                        DispatchQueue.main.async {
                                                            self.selectedFaceModel = faceModel
                                                            self.isActive = true
                                                        }
                                                    }
                                                }
                                                else {
                                                    self.selectedFaceModel = faceModel
                                                    self.isActive = true
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                            
                            if viewModel.faceModels.isEmpty, !viewModel.isLoading {
                                Text("Couldn't find any face in photo gallery. Add photos with faces and try rescain again!")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .padding()
                                    .padding(.bottom, 24)
                                
                            }
                            if viewModel.isLoading {
                                CustomProgressView(progress: $viewModel.loadingProgress)
                                    .frame(height: 52)
                                    .padding()
                                    .transition(.opacity)
                                
                            }
                            else {
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
                                        .transition(.opacity)
                                }
                                .frame(height: 52)
                            }
                        }
                        .padding(.top, 44)
                        
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
