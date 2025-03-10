//
//  MainNavButtonView.swift
//  iSalah
//
//  Created by Mert Türedü on 9.03.2025.
//

import SwiftUI

struct MainNavButtonView: View {
    
    @EnvironmentObject var salah: iSalahState
    let model: MainNavButtonModel
    
    init(_ model: MainNavButtonModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            buttonView
            Text(model.title)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .semibold,size: .s))
        }
        .onTapGesture {
            model.action()
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        MainNavButtonView(.init(icon: .tesbih, title: "Tesbih", action: { }))
    }
        .environmentObject(mockSalah)
}

private extension MainNavButtonView {
    var buttonView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
                
            RoundedRectangle(cornerRadius: 12)
                .stroke(ColorHandler.getColor(salah, for: .islam))
            
            ImageHandler.getIcon(salah, image: model.icon)
                .scaledToFit()
                .foregroundColor(ColorHandler.getColor(salah, for: .light))
                .frame(width: dw(0.1))
        }
        .frame(width: dw(0.2), height: dw(0.2))
    }
}
