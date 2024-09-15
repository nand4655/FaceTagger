//
//
// FaceGridView.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//
        

import SwiftUI

struct FaceGridView: View {
    let croppedFaceImages: [UIImage]
    private let columns = [GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40))]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<min(croppedFaceImages.count, 6), id: \.self) { index in
                if index == 5 && croppedFaceImages.count > 6 {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                } else {
                    Image(uiImage: croppedFaceImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    FaceGridView(croppedFaceImages: [])
}
