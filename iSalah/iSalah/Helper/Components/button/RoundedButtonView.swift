//
//  RoundedButtonView.swift
//  iSalah
//
//  Created by Mert Türedü on 7.03.2025.
//

import SwiftUI

struct RoundedButtonView: View {
    
    @EnvironmentObject var salah: iSalahState
    let text: LocalizedStringKey
    let action: () -> Void
    
    init(_ text: LocalizedStringKey,
         action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button {
            withAnimation(.linear) {
                action()
            }
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorHandler.getColor(salah, for: .gold))
                .frame(width: dw(0.25), height: dh(0.05))
                .overlay {
                    Text(text)
                        .foregroundStyle(
                            ColorHandler.getColor(salah, for: .light)
                        )
                        .font(
                            FontHandler.setDubaiFont(weight: .regular, size: .s)
                        )
                        .multilineTextAlignment(.center)
                }
        }
    }
}

#Preview {
    RoundedButtonView("") { }
        .environmentObject(mockSalah)
}
