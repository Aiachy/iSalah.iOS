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
        
        switch theme {
        case "Medina Evening":
            return Color(prayer.rawValue)
        case "Half Rose":
            return halfRoseColors(for: prayer)
        case "Arab Desert":
            return arabDesertColors(for: prayer)
        default:
            return Color(prayer.rawValue)
        }
        
        /// Half Rose Colors
        func halfRoseColors(for prayer: ColorHelper.original) -> Color {
            
            switch prayer {
            case .oneTrue:
                return Color(ColorHelper.rose.oneTrue.rawValue)
            case .dark:
                return Color(ColorHelper.rose.dark.rawValue)
            case .female:
                return Color(ColorHelper.rose.female.rawValue)
            case .male:
                return Color(ColorHelper.rose.male.rawValue)
            case .light:
                return Color(ColorHelper.rose.opaqRose.rawValue)
            case .horizon:
                return Color(ColorHelper.rose.softRose.rawValue)
            case .islamic:
                return Color(ColorHelper.rose.darkBlue.rawValue)
            case .islamicAlt:
                return Color(ColorHelper.rose.nightBlue.rawValue)
            case .shadow:
                return Color(ColorHelper.rose.deepPurple.rawValue)
            case .gold:
                return Color(ColorHelper.rose.roseNight.rawValue)
            }
        }
        
        func arabDesertColors(for prayer: ColorHelper.original) -> Color {
            switch prayer {
            case .oneTrue:
                return Color(ColorHelper.arab.oneTrue.rawValue)
            case .dark:
                return Color(ColorHelper.arab.dark.rawValue)
            case .female:
                return Color(ColorHelper.arab.female.rawValue)
            case .male:
                return Color(ColorHelper.arab.male.rawValue)
            case .light:
                return Color(ColorHelper.arab.desertSand.rawValue)
            case .horizon:
                return Color(ColorHelper.arab.goldSand.rawValue)
            case .islamic:
                return Color(ColorHelper.arab.desertNight.rawValue)
            case .islamicAlt:
                return Color(ColorHelper.arab.dirt.rawValue)
            case .shadow:
                return Color(ColorHelper.arab.nightStone.rawValue)
            case .gold:
                return Color(ColorHelper.arab.sandstorm.rawValue)
            }
        }
    }
    
   
    
}
