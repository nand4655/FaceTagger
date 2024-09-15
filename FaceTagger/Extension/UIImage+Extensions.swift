//
//
// UIImage+Extensions.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//


import Foundation
import UIKit
import Vision

extension UIImage {
    func cropFaces(from faceObservations: [VNFaceObservation], targetSize: CGSize = CGSize(width: 100, height: 100)) -> [UIImage] {
        var faceImages: [UIImage] = []
        
        for faceObservation in faceObservations {
            let boundingBox = faceObservation.boundingBox
            let size = self.size
            
            let x = boundingBox.origin.x * size.width
            let y = (1 - boundingBox.origin.y - boundingBox.height) * size.height
            let width = boundingBox.width * size.width
            let height = boundingBox.height * size.height
            
            let cropRect = CGRect(x: x, y: y, width: width, height: height)
            
            if let croppedCGImage = self.cgImage?.cropping(to: cropRect) {
                let croppedImage = UIImage(cgImage: croppedCGImage)
                let resizedImage = resizeImage(image: croppedImage, targetSize: targetSize)
                faceImages.append(resizedImage)
            }
        }
        
        return faceImages
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor that preserves aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Create a graphics context and draw the image in it
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        let origin = CGPoint(x: (targetSize.width - scaledImageSize.width) / 2, y: (targetSize.height - scaledImageSize.height) / 2)
        image.draw(in: CGRect(origin: origin, size: scaledImageSize))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
}
