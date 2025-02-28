//
//  FontHelper.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

struct FontHelper {
    
    enum Dubai: String, CaseIterable {
        case regular = "Dubai-Regular"
        case medium = "Dubai-Medium"
        case light = "Dubai-Light"
        case bold = "Dubai-Bold"
    }
    
    enum NewYork: CaseIterable {
        case black
        case blackItalic
        case bold
        case boldItalic
        case heavy
        case heavyItalic
        case medium
        case mediumItalic
        case regular
        case regularItalic
        case semibold
        case semiboldItalic
    }
    
    enum Size: CGFloat {
        case xxs = 10, xs = 12, s = 14, m = 16, l = 18, xl = 20, xxl = 24, xxxl = 28
        case h1 = 32, h2 = 36, h2_5 = 40, h3 = 42, h4 = 48
    }
}
