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
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized || status == .limited {
            return true
        } else {
            return await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                    continuation.resume(returning: newStatus == .authorized || newStatus == .limited)
                }
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
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            let deliveryMode: PHImageRequestOptionsDeliveryMode = status == .authorized ? .fastFormat : .opportunistic
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            options.deliveryMode = deliveryMode
            
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
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            
            let targetSize = CGSize(width:  asset.pixelWidth, height: asset.pixelHeight)
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                continuation.resume(returning: image)
            }
        }
    }
}
