//
//
// CustomProgressView.swift
// FaceTagger
//
// Created by Nand on 16/09/24
//
        

import SwiftUI

struct CustomProgressView: View {
    @Binding var progress: Double
    
    var body: some View {
        HStack(alignment: .top ){
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width , height: 12)
                        .foregroundStyle(Color.blue.opacity(0.3))
                        .cornerRadius(100)
                    Rectangle()
                        .frame(
                            width: min(progress * geometry.size.width,
                                       geometry.size.width),
                            height: 12
                        )
                        .foregroundColor(Color.blue)
                        .cornerRadius(100)
                }
                
            }
        }
    }
}
