//
//  FontHandler.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

struct FontHandler {
    
    static func setDubaiFont(weight: FontHelper.Dubai? = nil, size: FontHelper.Size? = nil) -> Font {
        if let weight = weight, let size = size {
            return Font.custom(weight.rawValue, size: size.rawValue)
        }
        
        if let weight = weight {
            return Font.custom(weight.rawValue, size: FontHelper.Size.m.rawValue)
        }
        
        if let size = size {
            return Font.custom(FontHelper.Dubai.regular.rawValue, size: size.rawValue)
        }
        
        return Font.custom(FontHelper.Dubai.regular.rawValue, size: FontHelper.Size.m.rawValue)
    }
 
}
