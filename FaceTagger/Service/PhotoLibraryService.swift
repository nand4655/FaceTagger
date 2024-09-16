//
//
// PhotoLibraryService.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//
        

import Photos
import SwiftUI

protocol IPhotoLibraryService {
    func requestPhotoLibraryAccess() async -> Bool
    func fetchPhotos() async -> [UIImage]
}

class PhotoLibraryService: IPhotoLibraryService {
    func requestPhotoLibraryAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func fetchPhotos() async -> [UIImage] {
        await withCheckedContinuation { continuation in
            var images = [UIImage]()
            let fetchOptions = PHFetchOptions()
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            
            allPhotos.enumerateObjects { (asset, index, stop) in
                imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: options) { (image, info) in
                    if let image = image {
                        images.append(image)
                    }
                }
            }
            continuation.resume(returning: images)
        }
    }
}
