//
//  FontHelper.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

struct FontHelper {
    
    enum Dubai: String {
        case regular = "Dubai-Regular"
        case medium = "Dubai-Medium"
        case light = "Dubai-Light"
        case bold = "Dubai-Bold"
    }
    
    enum newYork: String {
        case black = "new-york-medium_black"
        case blackItalic = "new-york-medium_black-italic"
        case bold = "new-york-medium_bold"
        case boldItalic = "new-york-medium_bold-italic"
        case heavy = "new-york-medium_heavy"
        case heavyItalic = "new-york-medium_heavy-italic"
        case medium = "new-york-medium_medium"
        case mediumItalic = "new-york-medium_medium-italic"
        case regular = "new-york-medium_regular"
        case regularItalic = "new-york-medium_regular-italic"
        case semibold = "new-york-medium_semibold"
        case semiboldItalic = "new-york-medium_semibold-italic"
    }
    
    enum Size: CGFloat {
        case xxs = 10, xs = 12, s = 14, m = 16, l = 18, xl = 20, xxl = 24, xxxl = 28
        case h1 = 32, h2 = 36, h2_5 = 40, h3 = 42, h4 = 48
    }
    
    
}
