//
//  CircleButtonView.swift
//  iSalah
//
//  Created by Mert Türedü on 12.03.2025.
//

import SwiftUI

struct CircleButtonView: View {
    
    @EnvironmentObject var salah: iSalahState
    let model: CircleButtonModel
    
    init (
        _ model: CircleButtonModel
    ) {
        self.model = model
    }
    
    var body: some View {
        ZStack {
            backgroundView
            ImageHandler.getIcon(salah, image: model.image)
                .scaledToFit()
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .padding(10)
        }
        .frame(width: dw(model.size))

        .onTapGesture {
            HapticManager.shared.tabSelection()

            withAnimation(.linear) {
                model.action()
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        CircleButtonView(.init(.heart, action: {
            
        }))
    }
    .environmentObject(mockSalah)
}

private extension CircleButtonView {
    
    var backgroundView: some View {
        ZStack {
            /// Background
            Circle()
                .fill(ColorHandler.getColor(salah, for: .islamicAlt))
            /// Stroke
            Circle()
                .stroke(ColorHandler.getColor(salah, for: .light), lineWidth: 0.5)
        }

    }
    
}
