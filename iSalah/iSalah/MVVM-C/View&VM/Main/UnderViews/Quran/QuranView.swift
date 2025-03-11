//
//  QuranView.swift
//  iSalah
//
//  Created by Mert Türedü on 10.03.2025.
//

import SwiftUI

struct QuranView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: QuranViewModel
    
    init(_ coordinator: MainCoordinatorPresenter) {
        _vm = StateObject(wrappedValue: QuranViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        VStack {
            SettingsHeaderView("Quran", back: vm.makeBackButton)
            ScrollView(.vertical) {
                
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        QuranView(.init())
    }
    .environmentObject(mockSalah)
}
