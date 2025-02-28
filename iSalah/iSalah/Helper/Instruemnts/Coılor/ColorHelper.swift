//
//  ColorHelper.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation

struct ColorHelper {
    
    enum original: String, CaseIterable {
        case oneTrue = "oneTrue"
        case dark = "dark"
        case female = "female"
        case male = "male"

        case light = "light"
        case horizon = "horizon"
        case islamic = "islamic"
        case islamicAlt = "islamicAlt"
        case shadow = "shadow"
        case gold = "gold"
    }
    
    enum rose: String, CaseIterable {
        case oneTrue = "oneTrue"
        case dark = "dark"
        case female = "female"
        case male = "male"
        
        case opaqRose = "opaqRose"
        case softRose = "softRose"
        case darkBlue = "darkBlue"
        case nightBlue = "nightBlue"
        case deepPurple = "deepPurple"
        case roseNight = "roseNight"
    }
    
    enum arab: String, CaseIterable {
        case oneTrue = "oneTrue"
        case dark = "dark"
        case female = "female"
        case male = "male"

        case desertSand = "desertSand"
        case goldSand = "goldSand"
        case desertNight = "desertNight"
        case dirt = "dirt"
        case nightStone = "nightStone"
        case sandstorm = "sandstorm"
    }
}
