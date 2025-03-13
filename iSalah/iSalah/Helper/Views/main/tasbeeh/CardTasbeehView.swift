//
//  CardTasbeehView.swift
//  iSalah
//
//  Created by Mert Türedü on 13.03.2025.
//

import SwiftUI

struct CardTasbeehView: View {
    
    @EnvironmentObject var salah: iSalahState
    let model: TasbeehModel
    let action: () -> Void
    
    init (
        _ model: TasbeehModel,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.action = action
    }
    
    var body: some View {
        ZStack {
            backgroundView
            HStack {
                cardContent
                Spacer()
                buttonView
                    .onTapGesture {
                        withAnimation(.linear) {
                            action()
                        }
                    }
            }
            .padding(.horizontal)
        }
        .frame(width: size9, height: dh(0.1))

    }
}

#Preview {
    ZStack {
        BackgroundView()
        CardTasbeehView(.init(id: 0, name: "Card Test", pressed: 0), action: { })
    }
    .environmentObject(mockSalah)
}

private extension CardTasbeehView {
    
    var backgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
                .shadow(color: ColorHandler.getColor(salah, for: .dark).opacity(0.25), radius: 4, y: 4)
            RoundedRectangle(cornerRadius: 12)
                .stroke(ColorHandler.getColor(salah, for: .islam))
        }
    }
    
    var cardContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(model.name)
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .m))
                .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
            
            Text("Count: \(model.pressed)")
                .font(FontHandler.setNewYorkFont(weight: .semibold, size: .xs))
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        }
        
    }
    
    var buttonView: some View {
        ZStack {
            Circle()
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .shadow(color: ColorHandler.getColor(salah, for: .light).opacity(0.25), radius: 5)
            Circle()
                .stroke(ColorHandler.getColor(salah, for: .shadow),lineWidth: 0.5)
            ImageHandler.getIcon(salah, image: .plus)
                .scaledToFit()
                .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
                .padding(13)
        }
        .frame(width: dw(0.12), height: dw(0.12))
    }
}

private extension CardTasbeehView {
    
    
    
}
