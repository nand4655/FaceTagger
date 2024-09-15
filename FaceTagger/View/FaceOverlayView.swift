//
//
// FaceOverlayView.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//
     
import UIKit
import Vision

class FaceOverlayView: UIView {
    var image: UIImage?
    var faceObservations: [VNFaceObservation] = []
    var tags: [VNFaceObservation: String] = [:]
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let image = image else { return }
        
        // Save the current graphics state
        context.saveGState()
        
        // Flip the context vertically to handle the image orientation
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Calculate the drawing rectangle to maintain the aspect ratio
        let imageAspectRatio = image.size.width / image.size.height
        let viewAspectRatio = bounds.size.width / bounds.size.height
        var drawingRect = bounds
        
        if imageAspectRatio > viewAspectRatio {
            // Image is wider than the view
            let scaledHeight = bounds.size.width / imageAspectRatio
            drawingRect = CGRect(x: 0, y: (bounds.size.height - scaledHeight) / 2, width: bounds.size.width, height: scaledHeight)
        } else {
            // Image is taller than the view
            let scaledWidth = bounds.size.height * imageAspectRatio
            drawingRect = CGRect(x: (bounds.size.width - scaledWidth) / 2, y: 0, width: scaledWidth, height: bounds.size.height)
        }
        
        // Draw the image
        context.draw(image.cgImage!, in: drawingRect)
        
        // Restore the graphics state
        context.restoreGState()
        
        // Draw face rectangles and tags
        for faceObservation in faceObservations {
            let boundingBox = faceObservation.boundingBox
            let size = drawingRect.size
            
            let x = drawingRect.origin.x + boundingBox.origin.x * size.width
            let y = drawingRect.origin.y + (1 - boundingBox.origin.y - boundingBox.height) * size.height
            let width = boundingBox.width * size.width
            let height = boundingBox.height * size.height
            
            let faceRect = CGRect(x: x, y: y, width: width, height: height)
            
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(2.0)
            context.stroke(faceRect)
            
            if let tag = tags[faceObservation] {
                let tagRect = CGRect(x: x, y: y + height + 5, width: width, height: 20)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: UIColor.red
                ]
                
                tag.draw(in: tagRect, withAttributes: attributes)
            }
        }
    }
}

