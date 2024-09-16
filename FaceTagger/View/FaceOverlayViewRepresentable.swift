//
//
// FaceOverlayViewRepresentable.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//
        
import SwiftUI
import Vision
import UIKit

struct FaceOverlayViewWrapper: View {
    var image: UIImage
    var faceObservations: [VNFaceObservation]
    var tags: [VNFaceObservation: String]
    @Binding var isActive: Bool // Receive the binding

    var onFaceSelected: ((VNFaceObservation) -> Void)?

    var body: some View {
        FaceOverlayViewRepresentable(
            image: image,
            faceObservations: faceObservations,
            tags: tags,
            onFaceLongTap: onFaceSelected
        )
        .onDisappear {
            // Reset isActive when navigating back
            isActive = false
        }
    }
}

struct FaceOverlayViewRepresentable: UIViewRepresentable {
    var image: UIImage
    var faceObservations: [VNFaceObservation]
    var tags: [VNFaceObservation: String]
    var onFaceLongTap: ((VNFaceObservation) -> Void)?
    
    func makeUIView(context: Context) -> FaceOverlayView {
        let view = FaceOverlayView()
        view.image = image
        view.isUserInteractionEnabled = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        view.addGestureRecognizer(longPressGesture)
        return view
    }
    
    func updateUIView(_ uiView: FaceOverlayView, context: Context) {
        uiView.faceObservations = faceObservations
        uiView.tags = tags
        uiView.setNeedsDisplay()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: FaceOverlayViewRepresentable
        
        init(_ parent: FaceOverlayViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            let location = gesture.location(in: gesture.view)

            for faceObservation in parent.faceObservations {
                let boundingBox = faceObservation.boundingBox
                let size = gesture.view?.bounds.size ?? .zero

                let x = boundingBox.origin.x * size.width
                let y = (1 - boundingBox.origin.y - boundingBox.height) * size.height
                let width = boundingBox.width * size.width
                let height = boundingBox.height * size.height

                let faceRect = CGRect(x: x, y: y, width: width, height: height)

                if faceRect.contains(location) {
                    parent.onFaceLongTap?(faceObservation)
                    break
                }
            }
        }
    }
}



