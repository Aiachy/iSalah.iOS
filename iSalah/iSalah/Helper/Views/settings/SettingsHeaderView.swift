//
//  SettingsHeaderView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct SettingsHeaderView: View {
    
    @EnvironmentObject var salah: iSalahState
    let title: LocalizedStringKey
    let back: () -> ()
    
    init(_ title: LocalizedStringKey,
         back: @escaping () -> Void) {
        self.title = title
        self.back = back
    }
    
    var body: some View {
        ZStack {
            Text(title)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
            HStack {
                backButtonView
                Spacer()
            }
        }
        .frame(width: size9, height: dh(0.06))
    }
}
//MARK: Preview
#Preview {
    ZStack {
        BackgroundView()
        SettingsHeaderView("Header View") { }
    }
    .environmentObject(mockSalah)
}
//MARK: Views
private extension SettingsHeaderView {
    
    var backButtonView: some View {
        
        RoundedRectangle(cornerRadius: 50)
            .stroke(ColorHandler.getColor(salah, for: .light), lineWidth: 0.5)
            .frame(width: dw(0.18), height: dh(0.035))
            .overlay {
                HStack {
                    ImageHandler.getIcon(salah, image: .back)
                        .scaledToFit()
                        .frame(width: dw(0.02))
                    Spacer()
                    Text("Back")
                        .font(FontHandler.setDubaiFont(weight: .bold, size: .xs))
                }
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .padding(.horizontal)
            }
            .onTapGesture {
                back()
            }
        
    }
    
}
