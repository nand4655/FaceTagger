//
//
// PhotoLibraryPermissionView.swift
// FaceTagger
//
// Created by Nand on 15/09/24
//


import SwiftUI

struct PhotoLibraryPermissionView: View {
    var body: some View {
        VStack {
            Image("degreed")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .padding(52)
            
            VStack(alignment: .leading) {
                Text("Allow access to your photos to detect faces.")
                    .font(.title)
                    .padding()
                Button {
                    openSettings()
                } label: {
                    Text("Allow Access")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(15)
                        .padding()
                }
                .frame(height: 52)
            }
        }
        .background(Color.base)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}


#Preview {
    PhotoLibraryPermissionView()
}
