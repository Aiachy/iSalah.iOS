//
//  SheetModifier.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

struct SheetModifier: ViewModifier {
    
    @EnvironmentObject var salah: iSalahState
    let borderColor: ColorHelper.original
    let height: CGFloat
    let opacity: CGFloat
    let corner: CGFloat
    
    init(borderC borderColor: ColorHelper.original = .gold,
         _ height: CGFloat,
         opa opacity: CGFloat = 0.9,
         corner: CGFloat = 36) {
        self.borderColor = borderColor
        self.height = height
        self.opacity = opacity
        self.corner = corner
    }
    
    func body(content: Content) -> some View {
        content
            .presentationDetents([.fraction(height)])
            .presentationCornerRadius(corner)
            .presentationBackgroundInteraction(.enabled)
            .overlay(
                RoundedRectangle(cornerRadius: corner)
                    .stroke(ColorHandler.getColor(salah, for: borderColor), lineWidth: 5)
                    .ignoresSafeArea()
                    .padding(.bottom,-10)
                    .allowsHitTesting(false)
            )
           
            .ignoresSafeArea()

    }
}
