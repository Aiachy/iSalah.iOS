//
//  BackgroundView.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI

struct BackgroundView: View {
    @EnvironmentObject var salah: iSalahState
    
    var body: some View {
        ZStack {
            linearBackgroundColorView
            elaborationView
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
        .environmentObject(mockSalah)
}

extension BackgroundView {
    
    private var linearBackgroundColorView: some View {
        LinearGradient(
            stops: [
                .init(color: ColorHandler.getColor(salah, for: .islamic), location: 0),
                .init(color: ColorHandler.getColor(salah, for: .islamicAlt), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var elaborationView: some View {
        ImageHandler.getMassive(salah, image: [.bg1, .bg2, .bg3, .bg4].randomElement() ?? .bg1)
            .opacity(0.02)
    }
    
}
