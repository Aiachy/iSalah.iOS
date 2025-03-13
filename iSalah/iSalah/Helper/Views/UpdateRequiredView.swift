//
//  UpdateRequiredView.swift
//  iSalah
//
//  Created by Claude on 13.03.2025.
//

import SwiftUI

struct UpdateRequiredView: View {
    
    @EnvironmentObject var salah: iSalahState
    private let updateURL: String
    
    init(updateURL: String = "https://apps.apple.com/tr/app/aisalah/id6742526415") {
        self.updateURL = updateURL
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Icon
            ImageHandler.getIcon(salah, image: .allah)
                .scaledToFit()
                .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
                
            
            Text("New Version Available")
                .foregroundColor(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .heavy, size: .h1))
            
            Text("A new version of the AISalah app is available. We recommend you update it for a better experience.")
                .foregroundColor(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setDubaiFont(weight: .light, size: .m))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            
            VStack(spacing: 16) {
                Button(action: {
                    openAppStore()
                }) {
                    Text("Update on App Store")
                        .foregroundColor(ColorHandler.getColor(salah, for: .horizon))
                        .font(FontHandler.setDubaiFont(weight: .bold, size: .m))
                }
                .frame(width: size9)
                .padding(.vertical)
                .background(ColorHandler.getColor(salah, for: .islam))
                .cornerRadius(12)
                
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
    }
    
    private func openAppStore() {
        if let url = URL(string: updateURL) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    UpdateRequiredView()
    .environmentObject(mockSalah)
}
