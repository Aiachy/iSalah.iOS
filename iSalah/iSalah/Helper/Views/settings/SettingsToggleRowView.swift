//
//  SettingsToggleRowView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct SettingsToggleRowView: View {
    
    @EnvironmentObject var salah: iSalahState
    let model: SettingsToggleRowModel
    
    init (
        _ model: SettingsToggleRowModel
    
    ) {
        self.model = model
    }
    
    var body: some View {
        HStack {
            Text(model.title)
                .font(FontHandler.setDubaiFont(weight: model.font, size: model.size))
            Spacer()
            CustomToggleView(model.$isOn)
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        
    }
}

#Preview {
    ZStack {
        BackgroundView()
        SettingsToggleRowView(.init(id: "1", isOn: .constant(true), font: .bold, size: .l, title: "Test" ))
    }
    .environmentObject(mockSalah)
}
