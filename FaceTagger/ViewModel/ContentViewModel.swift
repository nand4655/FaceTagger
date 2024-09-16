//
//
// ContentViewModel.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//


import SwiftUI
import Vision
import Photos

class ContentViewModel: ObservableObject {
    @Published var faceModels: [FaceImageModel] = []
    @Published var isLoading = false
    @Published var loadingProgress: Double = 0.0
    @Published var permissionGranted = false
    
    private let photoLibraryService: IPhotoLibraryService
    private let faceDetectionService: IFaceDetection
    
    init(photoLibraryService: IPhotoLibraryService = PhotoLibraryService(),
         faceDetectionService: IFaceDetection = FaceDetectionService()) {
        self.photoLibraryService = photoLibraryService
        self.faceDetectionService = faceDetectionService
    }
    
    @MainActor
    func onAppear() async {
        let _ = await photoLibraryService.requestPhotoLibraryAccess()
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            setPermissionStatus(true)
            await self.loadPhotos()
        case .denied, .restricted, .notDetermined:
            setPermissionStatus(false)
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    func loadPhotos() async {
        updateProgress(0.0)
        setLoading(true)
        
        let images = await photoLibraryService.fetchPhotos()
        let totalImages = images.count
        
        for (index, image) in images.enumerated() {
            let faces = await faceDetectionService.detectFaces(in: image)
            appendFaceModel(faces: faces, image: image)
            updateProgress(Double(index + 1) / Double(totalImages))
        }
        
        //TODO: Remove this delay. This delay is to simulate progress
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.setLoading(false)
        }
    }
    
    private func appendFaceModel(faces: [VNFaceObservation]?, image: UIImage) {
        guard let faceObservations = faces, !faceObservations.isEmpty else { return }
        
        Task { @MainActor [weak self] in
            let croppedFaceImages = image.cropFaces(from: faceObservations)
            self?.faceModels.append(FaceImageModel(image: image, observations: faceObservations, croppedFaceImages: croppedFaceImages))
        }
    }
    
    private func updateProgress(_ progress: Double) {
        Task { @MainActor [weak self] in
            self?.loadingProgress = progress
        }
    }
    
    private func setPermissionStatus(_ status: Bool) {
        Task { @MainActor [weak self] in
            self?.permissionGranted = status
        }
    }
    
    private func setLoading(_ status: Bool) {
        Task { @MainActor [weak self] in
            self?.isLoading = status
        }
    }
    
    
    func updateTag(_ faceImageId: UUID, for face: VNFaceObservation, with tag: String) {
        if let index = faceModels.firstIndex(where: { $0.id == faceImageId }) {
            Task { @MainActor [weak self] in
                self?.faceModels[index].updateTag(for: face, with: tag)
            }
        }
    }
    
    func clearLastScan() {
        Task { @MainActor [weak self] in
            self?.faceModels = []
        }
    }
}
