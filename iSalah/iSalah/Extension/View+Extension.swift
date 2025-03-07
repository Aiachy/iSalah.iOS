//
//  View+Extension.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

extension View {
    
    func dw(_ double: Double) -> Double {
        uiWidth * double
    }
    
    func dh(_ double: Double) -> Double {
        uiHeight * double
    }
    
}

extension View {
    
    func rotate(_ angle: Double) -> some View {
        self
            .rotationEffect(.degrees(-30))
    }
    
}
