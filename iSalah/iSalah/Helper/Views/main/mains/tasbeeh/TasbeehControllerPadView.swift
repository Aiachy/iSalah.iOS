//
//  TasbeehControllerPadView.swift
//  iSalah
//
//  Created by Mert Türedü on 13.03.2025.
//

import SwiftUI

struct TasbeehControllerPadView: View {
    
    @EnvironmentObject var salah: iSalahState
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        TasbeehControllerPadView()
    }
    .environmentObject(mockSalah)
}
