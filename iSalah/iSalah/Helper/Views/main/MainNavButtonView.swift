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
        Group {
            if model.version == 0 {
                firstVersion
            } else {
                secondVersion
            }
        }
        .onTapGesture {
            model.action()
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        MainNavButtonView(.init(.tesbih, version: 1, title: "Tesbih", action: { }))
    }
        .environmentObject(mockSalah)
}

private extension MainNavButtonView {
    
    private var firstVersion: some View {
        VStack {
            /// iconic
            ZStack {
                makeButtonView(CGSize(width: 0.2, height: 0.2))
                iconView
            }
            Text(model.title)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .semibold,size: .s))
        }
    }
    
    private var secondVersion: some View {
        ZStack {
            makeButtonView(CGSize(width: 0.44, height: 0.2))
            HStack {
                iconView
                Spacer()
                Text(model.title)
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setNewYorkFont(weight: .semibold,size: .l))
            }
            .padding(.horizontal)
        }
        .frame(width: dw(0.44))
    }
    
}

private extension MainNavButtonView {
    func makeButtonView(_ size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
                
            RoundedRectangle(cornerRadius: 12)
                .stroke(ColorHandler.getColor(salah, for: .islam))
            
        }
        .frame(width: dw(size.width), height: dw(size.height))
    }
    
    var iconView: some View {
        ImageHandler.getIcon(salah, image: model.icon)
            .scaledToFit()
            .foregroundColor(ColorHandler.getColor(salah, for: .light))
            .frame(width: dw(0.1))
    }
}
