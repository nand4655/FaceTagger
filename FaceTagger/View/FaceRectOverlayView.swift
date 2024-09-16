//
//
// SwiftUIView.swift
// FaceTagger
//
// Created by Nand on 16/09/24
//
        

import SwiftUI
import Vision

import SwiftUI
import Vision

struct FaceRectOverlayView: View {
    let image: UIImage
    let faceObservations: [VNFaceObservation]
    let tags: [VNFaceObservation: String]
    var onFaceLongTap: ((VNFaceObservation) -> Void)?
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(currentScale)
                    .offset(x: currentOffset.width, y: currentOffset.height)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    self.currentScale = self.lastScale * value
                                }
                                .onEnded { value in
                                    self.lastScale = self.currentScale
                                },
                            DragGesture()
                                .onChanged { value in
                                    self.currentOffset = CGSize(
                                        width: self.lastOffset.width + value.translation.width,
                                        height: self.lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { value in
                                    self.lastOffset = self.currentOffset
                                }
                        )
                    )
                
                ForEach(faceObservations, id: \.self) { faceObservation in
                    let boundingBox = faceObservation.boundingBox
                    let rect = self.convertBoundingBox(boundingBox, imageSize: image.size, viewSize: geometry.size)
                    
                    VStack {
                        Rectangle()
                            .stroke(Color.red, lineWidth: 2)
                            .frame(width: rect.width, height: rect.height)
                            .contentShape(Rectangle()) // Ensure the entire rectangle is tappable
                            .onTapGesture {
                                onFaceLongTap?(faceObservation)
                            }
                        
                        if let tag = tags[faceObservation] {
                            Text(tag)
                                .foregroundColor(.red)
                        }
                    }
                    .position(x: rect.midX, y: rect.midY) // Adjust the position to place the tag below the rectangle
                    .scaleEffect(currentScale)
                    .offset(x: currentOffset.width, y: currentOffset.height)
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
