//
//
// CircularProgressView.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//
        

import SwiftUI

struct CircularProgressView: View {
    @Binding var progress: Double
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10.0)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear)
                
                Text(String(format: "%.0f %%", min(self.progress, 1.0) * 100.0))
                    .font(.largeTitle)
                    .bold()
            }
            .padding(20)
            
            Text("Scan in progress...")
                .font(.headline)
                .padding(.top, 10)
        }
    }
}
