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

struct FaceImageModel: Identifiable {
    let id = UUID()
    let image: UIImage
    let observations: [VNFaceObservation]
    let croppedFaceImages: [UIImage]
    var tags: [VNFaceObservation: String] = [:]
    
    mutating func updateTag(for face: VNFaceObservation, with tag: String) {
        tags[face] = tag
    }
}
