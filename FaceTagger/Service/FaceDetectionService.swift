//
//
// FaceDetectionService.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//
        

import Vision
import UIKit

protocol IFaceDetection {
    func detectFaces(in image: UIImage) async -> [VNFaceObservation]?
}

class FaceDetectionService: IFaceDetection {
    func detectFaces(in image: UIImage) async -> [VNFaceObservation]? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        
        let request = VNDetectFaceRectanglesRequest()
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    #if targetEnvironment(simulator)
                    request.usesCPUOnly = true
                    #endif
                    try handler.perform([request])
                    continuation.resume(returning: request.results)
                } catch {
                    print("Failed to perform face detection: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
