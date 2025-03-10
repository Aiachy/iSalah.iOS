//
//  SettingsSubTittleView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct SettingsSubTittleView: View {
    
    @EnvironmentObject var salah: iSalahState
    let text: String
    
    init(
        _ text: String
    ) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Text(text)
                .font(FontHandler.setDubaiFont(weight: .bold, size: .m))
                .background(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 1)
                }
            Spacer()
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
    }
}

#Preview {
    ZStack {
        BackgroundView()
        SettingsSubTittleView("Settings Sub Title Text")
    }
    .environmentObject(mockSalah)
}
