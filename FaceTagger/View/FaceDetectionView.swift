//
//
// SwiftUIView.swift
// FaceTagger
//
// Created by Nand on 16/09/24
//
        

import SwiftUI
import Vision

struct FaceDetectionView: View {
    let image: UIImage
    let faceObservations: [VNFaceObservation]
    let tags: [VNFaceObservation: String]
    var onFaceLongTap: ((VNFaceObservation) -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                ForEach(faceObservations, id: \.self) { faceObservation in
                    let boundingBox = faceObservation.boundingBox
                    let rect = self.convertBoundingBox(boundingBox, imageSize: image.size, viewSize: geometry.size)
                    
                    VStack {
                        Rectangle()
                            .stroke(Color.red, lineWidth: 2)
                            .frame(width: rect.width, height: rect.height)
                            .contentShape(Rectangle()) // Ensure the entire rectangle is tappable
                            .onTapGesture {
                                print("Face details: \(faceObservation)")
                                onFaceLongTap?(faceObservation)
                            }
                        
                        if let tag = tags[faceObservation] {
                            Text(tag)
                                .foregroundColor(.red)
                                .padding(2)
                        }
                    }
                    .position(x: rect.midX, y: rect.midY) // Adjust the position to place the tag below the rectangle
                }
            }
        }
    }
    
    private func convertBoundingBox(_ boundingBox: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
        let widthRatio = viewSize.width / imageSize.width
        let heightRatio = viewSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let xOffset = (viewSize.width - scaledImageSize.width) / 2
        let yOffset = (viewSize.height - scaledImageSize.height) / 2
        
        let rect = CGRect(
            x: boundingBox.origin.x * scaledImageSize.width + xOffset,
            y: (1 - boundingBox.origin.y - boundingBox.height) * scaledImageSize.height + yOffset,
            width: boundingBox.width * scaledImageSize.width,
            height: boundingBox.height * scaledImageSize.height
        )
        
        return rect
    }
}
