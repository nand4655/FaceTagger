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
    func fetchPhotos() async -> [PHAsset]
    func fetchThumnbnail(asset: PHAsset, thumbnail: Bool) async -> UIImage?
    func fetchImage(asset: PHAsset) async -> UIImage?
}

class PhotoLibraryService: IPhotoLibraryService {
    func requestPhotoLibraryAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func fetchPhotos() async -> [PHAsset] {
        await withCheckedContinuation { continuation in
            var allAssets = [PHAsset]()
            let fetchOptions = PHFetchOptions()
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            allPhotos.enumerateObjects { (asset, index, stop) in
                allAssets.append(asset)
            }
            continuation.resume(returning: allAssets)
        }
    }
    
    func fetchThumnbnail(asset: PHAsset, thumbnail: Bool) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .fastFormat
            
            let targetSize = CGSize(width:  200, height: 200)
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                continuation.resume(returning: image)
            }
        }
    }
    
    func fetchImage(asset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            
            let targetSize = CGSize(width:  asset.pixelWidth, height: asset.pixelHeight)
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                continuation.resume(returning: image)
            }
        }
    }
}
