//
//  ColorHandler.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI

struct ColorHandler {
    
    static func getColor(_ state: iSalahState, for prayer: ColorHelper.original) -> Color {
        let theme = state.user.appInfo.theme
        
        return Color(prayer.rawValue)
    }
}
