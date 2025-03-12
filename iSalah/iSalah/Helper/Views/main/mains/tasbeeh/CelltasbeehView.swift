//
//  CelltasbeehView.swift
//  iSalah
//
//  Created by Mert Türedü on 13.03.2025.
//

import SwiftUI

struct CelltasbeehView: View {
    
    @EnvironmentObject var salah: iSalahState
    
    var body: some View {
        ZStack {
            
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        CelltasbeehView()
    }
    .environmentObject(mockSalah)
}
