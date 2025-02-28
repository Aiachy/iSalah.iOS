//
//  SettingsToggleRowView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct SettingsToggleRowView: View {
    
    @EnvironmentObject var salah: iSalahState
    @Binding var isOn: Bool
    let title: LocalizedStringKey
    
    init (
        _ isOn: Binding<Bool>,
        title: LocalizedStringKey
    ) {
        _isOn = isOn
        self.title = title
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
            Spacer()
            CustomToggleView($isOn)
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        .frame(width: size9)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        SettingsToggleRowView(.constant(true) , title: "Test")
    }
    .environmentObject(mockSalah)
}
