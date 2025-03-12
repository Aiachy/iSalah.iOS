//
//  SettingsHeaderView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct SettingsHeaderView<T:View>: View {
    
    @EnvironmentObject var salah: iSalahState
    let title: LocalizedStringKey
    let content: T
    let back: () -> ()
    
    init(_ title: LocalizedStringKey,
         @ViewBuilder content: @escaping () -> T = { Text("")},
         back: @escaping () -> Void) {
        self.title = title
        self.content = content()
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
        HStack(spacing: 5) {
            /// Icon
            ImageHandler.getIcon(salah, image: .back)
                .scaledToFit()
                .frame(width: dw(0.025), height: dh(0.036))
                
            /// Title
            Text("Back")
                .font( FontHandler.setDubaiFont(weight: .bold, size: .xs) )
                
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke( ColorHandler.getColor(salah, for: .light), lineWidth: 0.5 )
                .padding(-4)
                .padding(.horizontal, -8)
        }
        .onTapGesture { withAnimation(.linear) { back() } }
        .padding(.horizontal,12)
    }
    
}
