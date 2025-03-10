//
//  SettingsToggleRowModel.swift
//  iSalah
//
//  Created by Mert Türedü on 9.03.2025.
//

import SwiftUI

struct SettingsToggleRowModel: Identifiable {
    let id: String
    @Binding var isOn: Bool
    let font: FontHelper.Dubai
    let size: FontHelper.Size
    let title: String
    
    init(id: String = UUID().uuidString,
         isOn: Binding<Bool>,
         font: FontHelper.Dubai = .medium,
         size: FontHelper.Size = .l,
         title: String) {
        self.id = id
        _isOn = isOn
        self.font = font
        self.size = size
        self.title = title
    }
}
