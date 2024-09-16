//
//
// FaceImageModel.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//
        

import Foundation
import SwiftUI
import Vision
import Photos

struct FaceImageModel: Identifiable {
    let id = UUID()
    let asset: PHAsset
    var image: UIImage?
    let thumbnail: UIImage
    var observations: [VNFaceObservation]?
    let croppedFaceImages: [UIImage]?
    var tags: [VNFaceObservation: String] = [:]
    
    mutating func updateTag(for face: VNFaceObservation, with tag: String) {
        tags[face] = tag
    }
    
    mutating func updateFaceObservation(observations: [VNFaceObservation]?, with image: UIImage?) {
        self.observations = observations
        self.image = image
    }
}
